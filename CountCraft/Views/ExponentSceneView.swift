//
//  ExponentSceneView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI
import SceneKit
import UIKit

struct ExponentSceneView: View {
    let base: Int
    let depth: Int
    let color: Color

    @State private var allowsUserControl: Bool
    @State private var didScheduleControl = false
    @State private var sceneBundle: SceneBundle

    init(base: Int, depth: Int, color: Color) {
        self.base = base
        self.depth = depth
        self.color = color
        let startsInteractive = (4...9).contains(depth)
        _allowsUserControl = State(initialValue: startsInteractive)
        _sceneBundle = State(initialValue: Self.buildScene(base: base, depth: depth, color: color))
    }

    var body: some View {
        SceneView(scene: sceneBundle.scene, pointOfView: sceneBundle.cameraNode, options: sceneOptions)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onAppear {
                scheduleCameraControlIfNeeded()
            }
            .onChange(of: base) { _, _ in
                rebuildScene()
            }
            .onChange(of: depth) { _, _ in
                rebuildScene()
            }
    }

    private var sceneOptions: SceneView.Options {
        var options: SceneView.Options = [.autoenablesDefaultLighting]
        if allowsUserControl {
            options.insert(.allowsCameraControl)
        }
        return options
    }

    private struct SceneBundle {
        let scene: SCNScene
        let cameraNode: SCNNode
    }

    private static func buildScene(base: Int, depth: Int, color: Color) -> SceneBundle {
        let scene = SCNScene()
        let root = scene.rootNode
        let container = SCNNode()
        root.addChildNode(container)

        let cubeSize: CGFloat = 0.8
        let spacing: CGFloat = 0.22
        let step = cubeSize + spacing
        let extent = max(base, 1)
        let baseColor = UIColor(color).withAlphaComponent(0.9)
        let materials = Self.tintedMaterials(baseColor: baseColor, count: extent)
        let box = SCNBox(width: cubeSize, height: cubeSize, length: cubeSize, chamferRadius: 0)

        let usesAnimatedScene = (4...12).contains(depth)
        let cameraNode: SCNNode
        if usesAnimatedScene {
            cameraNode = Self.buildAnimatedExponentScene(
                depth: depth,
                extent: extent,
                step: step,
                spacing: spacing,
                box: box,
                materials: materials,
                color: color,
                container: container,
                root: root
            )
        } else {
            let groupSpacing = spacing * 3
            Self.placeBlocks(
                depth: depth,
                origin: SCNVector3(0, 0, 0),
                step: step,
                groupSpacing: groupSpacing,
                extent: extent,
                box: box,
                materials: materials,
                container: container
            )
            cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
        }

        let bounds = container.boundingBox
        let minBounds = bounds.min
        let maxBounds = bounds.max
        let center = SCNVector3(
            (minBounds.x + maxBounds.x) / 2,
            (minBounds.y + maxBounds.y) / 2,
            (minBounds.z + maxBounds.z) / 2
        )
        if !usesAnimatedScene {
            container.position = SCNVector3(-center.x, -center.y, -center.z)
        }

        let maxDimension = max(
            max(maxBounds.x - minBounds.x, maxBounds.y - minBounds.y),
            maxBounds.z - minBounds.z
        )
        if !usesAnimatedScene {
            cameraNode.camera?.fieldOfView = 50
            cameraNode.camera?.automaticallyAdjustsZRange = true
            cameraNode.position = SCNVector3(0, 0, Float(maxDimension * 2.4))
            cameraNode.camera?.zNear = 0.01
            cameraNode.camera?.zFar = Double(maxDimension * 20.0)
            root.addChildNode(cameraNode)
        }

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(Float(maxDimension), Float(maxDimension), Float(maxDimension))
        root.addChildNode(lightNode)

        let phase = ((depth - 1) % 3) + 1
        if !usesAnimatedScene {
            if phase == 3 {
                let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 16)
                container.runAction(SCNAction.repeatForever(rotate))
            } else {
                container.eulerAngles = SCNVector3(-0.35, 0.45, 0)
            }
        }

        return SceneBundle(scene: scene, cameraNode: cameraNode)
    }

    private func scheduleCameraControlIfNeeded() {
        guard depth >= 10 else { return }
        guard !didScheduleControl else { return }
        didScheduleControl = true
        let delay: TimeInterval = 5.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            allowsUserControl = true
        }
    }

    private func rebuildScene() {
        sceneBundle = Self.buildScene(base: base, depth: depth, color: color)
        let startsInteractive = (4...9).contains(depth)
        allowsUserControl = startsInteractive
        didScheduleControl = false
        scheduleCameraControlIfNeeded()
    }

    private static func tintIndex(x: Int, y: Int, z: Int, extent: Int) -> Int {
        guard extent > 1 else { return 0 }
        let mix = (x + y + z) % extent
        return mix
    }

    private static func tintedMaterials(baseColor: UIColor, count: Int) -> [SCNMaterial] {
        let safeCount = max(count, 1)
        return (0..<safeCount).map { index in
            let material = SCNMaterial()
            material.diffuse.contents = baseColor.adjustedBrightness(factor: Self.tintFactor(index: index, count: safeCount))
            material.lightingModel = .lambert
            return material
        }
    }

    private static func tintFactor(index: Int, count: Int) -> CGFloat {
        guard count > 1 else { return 1.0 }
        let ratio = CGFloat(index) / CGFloat(count - 1)
        return 0.7 + (ratio * 0.4)
    }

    private static func buildAnimatedExponentScene(
        depth: Int,
        extent: Int,
        step: CGFloat,
        spacing: CGFloat,
        box: SCNBox,
        materials: [SCNMaterial],
        color: Color,
        container: SCNNode,
        root: SCNNode
    ) -> SCNNode {
        let detailContainer = SCNNode()
        let groupsContainer = SCNNode()
        container.addChildNode(detailContainer)
        container.addChildNode(groupsContainer)

        Self.placeBlocks(
            depth: 3,
            origin: SCNVector3(0, 0, 0),
            step: step,
            groupSpacing: spacing * 3,
            extent: extent,
            box: box,
            materials: materials,
            container: detailContainer
        )
        let detailBounds = detailContainer.boundingBox
        let detailMin = detailBounds.min
        let detailMax = detailBounds.max
        let detailCenter = SCNVector3(
            (detailMin.x + detailMax.x) / 2,
            (detailMin.y + detailMax.y) / 2,
            (detailMin.z + detailMax.z) / 2
        )
        detailContainer.position = SCNVector3(-detailCenter.x, -detailCenter.y, -detailCenter.z)

        let groupGap = spacing * 4
        let groupSpan = CGFloat(extent - 1) * step + (box.width)
        let groupStep = groupSpan + groupGap

        let xCount = extent
        let yCount = depth >= 5 ? extent : 1
        let zCount = depth >= 6 ? extent : 1
        let fullSpanX = groupSpan + CGFloat(max(xCount - 1, 0)) * groupStep
        let fullSpanY = groupSpan + CGFloat(max(yCount - 1, 0)) * groupStep
        let fullSpanZ = groupSpan + CGFloat(max(zCount - 1, 0)) * groupStep
        let fullSpan = max(fullSpanX, fullSpanY, fullSpanZ)
        let cubeSpan = fullSpan
        let cubeCenter = SCNVector3(
            Float(CGFloat(max(xCount - 1, 0)) * groupStep / 2),
            Float(CGFloat(max(yCount - 1, 0)) * groupStep / 2),
            Float(CGFloat(max(zCount - 1, 0)) * groupStep / 2)
        )

        let groupMaterial = SCNMaterial()
        groupMaterial.diffuse.contents = UIColor(color).withAlphaComponent(0.85)
        groupMaterial.lightingModel = .lambert
        groupMaterial.writesToDepthBuffer = false
        groupMaterial.readsFromDepthBuffer = true
        groupMaterial.transparencyMode = .aOne

        let groupBox = SCNBox(width: groupSpan, height: groupSpan, length: groupSpan, chamferRadius: 0)
        groupBox.materials = [groupMaterial]

        groupsContainer.renderingOrder = 10

        for z in 0..<zCount {
            for y in 0..<yCount {
                for x in 0..<xCount {
                    if x == 0 && y == 0 && z == 0 { continue }
                    let node = SCNNode(geometry: groupBox)
                    node.position = SCNVector3(
                        Float(CGFloat(x) * groupStep),
                        Float(CGFloat(y) * groupStep),
                        Float(CGFloat(z) * groupStep)
                    )
                    groupsContainer.addChildNode(node)
                }
            }
        }

        var outerSpan: CGFloat = cubeSpan
        var outerCenter = cubeCenter

        if depth >= 7 {
            let outerContainer = SCNNode()
            container.addChildNode(outerContainer)

            let outerMaterial = SCNMaterial()
            outerMaterial.diffuse.contents = UIColor(color).withAlphaComponent(0.85)
            outerMaterial.lightingModel = .lambert
            outerMaterial.writesToDepthBuffer = false
            outerMaterial.readsFromDepthBuffer = true
            outerMaterial.transparencyMode = .aOne

            let outerBox = SCNBox(
                width: cubeSpan,
                height: cubeSpan,
                length: cubeSpan,
                chamferRadius: 0
            )
            outerBox.materials = [outerMaterial]

            outerContainer.renderingOrder = 20

            let outerStep = cubeSpan + groupGap
            let outerX = extent
            let outerY = depth >= 8 ? extent : 1
            let outerZ = depth >= 9 ? extent : 1
            let outerSpanX = cubeSpan + CGFloat(max(outerX - 1, 0)) * outerStep
            let outerSpanY = cubeSpan + CGFloat(max(outerY - 1, 0)) * outerStep
            let outerSpanZ = cubeSpan + CGFloat(max(outerZ - 1, 0)) * outerStep
            outerSpan = max(outerSpanX, outerSpanY, outerSpanZ)
            outerCenter = SCNVector3(
                cubeCenter.x + Float(CGFloat(max(outerX - 1, 0)) * outerStep / 2),
                cubeCenter.y + Float(CGFloat(max(outerY - 1, 0)) * outerStep / 2),
                cubeCenter.z + Float(CGFloat(max(outerZ - 1, 0)) * outerStep / 2)
            )

            for z in 0..<outerZ {
                for y in 0..<outerY {
                    for x in 0..<outerX {
                        if x == 0 && y == 0 && z == 0 { continue }
                        let node = SCNNode(geometry: outerBox)
                        node.position = SCNVector3(
                            cubeCenter.x + Float(CGFloat(x) * outerStep),
                            cubeCenter.y + Float(CGFloat(y) * outerStep),
                            cubeCenter.z + Float(CGFloat(z) * outerStep)
                        )
                        outerContainer.addChildNode(node)
                    }
                }
            }
            outerContainer.opacity = 0
            let outerFade = SCNAction.sequence([SCNAction.wait(duration: 1.8), SCNAction.fadeIn(duration: 1.0)])
            outerContainer.runAction(outerFade)
        }

        var outer2Span = outerSpan
        var outer2Center = outerCenter

        if depth >= 10 {
            let outer2Container = SCNNode()
            container.addChildNode(outer2Container)

            let outer2Material = SCNMaterial()
            outer2Material.diffuse.contents = UIColor(color).withAlphaComponent(0.85)
            outer2Material.lightingModel = .lambert
            outer2Material.writesToDepthBuffer = false
            outer2Material.readsFromDepthBuffer = true
            outer2Material.transparencyMode = .aOne

            let outer2Box = SCNBox(
                width: outerSpan,
                height: outerSpan,
                length: outerSpan,
                chamferRadius: 0
            )
            outer2Box.materials = [outer2Material]

            outer2Container.renderingOrder = 30

            let outer2Step = outerSpan + groupGap
            let outer2X = extent
            let outer2Y = depth >= 11 ? extent : 1
            let outer2Z = depth >= 12 ? extent : 1
            let outer2SpanX = outerSpan + CGFloat(max(outer2X - 1, 0)) * outer2Step
            let outer2SpanY = outerSpan + CGFloat(max(outer2Y - 1, 0)) * outer2Step
            let outer2SpanZ = outerSpan + CGFloat(max(outer2Z - 1, 0)) * outer2Step
            outer2Span = max(outer2SpanX, outer2SpanY, outer2SpanZ)
            outer2Center = SCNVector3(
                outerCenter.x + Float(CGFloat(max(outer2X - 1, 0)) * outer2Step / 2),
                outerCenter.y + Float(CGFloat(max(outer2Y - 1, 0)) * outer2Step / 2),
                outerCenter.z + Float(CGFloat(max(outer2Z - 1, 0)) * outer2Step / 2)
            )

            for z in 0..<outer2Z {
                for y in 0..<outer2Y {
                    for x in 0..<outer2X {
                        if x == 0 && y == 0 && z == 0 { continue }
                        let node = SCNNode(geometry: outer2Box)
                        node.position = SCNVector3(
                            outerCenter.x + Float(CGFloat(x) * outer2Step),
                            outerCenter.y + Float(CGFloat(y) * outer2Step),
                            outerCenter.z + Float(CGFloat(z) * outer2Step)
                        )
                        outer2Container.addChildNode(node)
                    }
                }
            }
            outer2Container.opacity = 0
            let outer2Fade = SCNAction.sequence([SCNAction.wait(duration: 2.6), SCNAction.fadeIn(duration: 1.0)])
            outer2Container.runAction(outer2Fade)
        }

        let combinedBounds = container.boundingBox
        let minBounds = combinedBounds.min
        let maxBounds = combinedBounds.max
        let center = SCNVector3(
            (minBounds.x + maxBounds.x) / 2,
            (minBounds.y + maxBounds.y) / 2,
            (minBounds.z + maxBounds.z) / 2
        )
        // For depth 7+, center on the detail cube initially (camera will pan to show outer container later)
        if depth >= 7 {
            container.position = SCNVector3(-detailCenter.x, -detailCenter.y, -detailCenter.z)
        } else {
            container.position = SCNVector3(-center.x, -center.y, -center.z)
        }

        let detailSpan = max(
            max(detailMax.x - detailMin.x, detailMax.y - detailMin.y),
            detailMax.z - detailMin.z
        )
        let maxSpan = max(fullSpan, outerSpan, outer2Span)
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 50
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = Double(maxSpan * 20.0)
        cameraNode.position = SCNVector3(0, 0, Float(detailSpan * 2.2))
        root.addChildNode(cameraNode)

        let targetNode = SCNNode()
        targetNode.position = SCNVector3(0, 0, 0)
        root.addChildNode(targetNode)
        cameraNode.constraints = [SCNLookAtConstraint(target: targetNode)]

        groupsContainer.opacity = 0
        let wait = SCNAction.wait(duration: 0.8)
        let fadeIn = SCNAction.fadeIn(duration: 1.0)
        groupsContainer.runAction(SCNAction.sequence([wait, fadeIn]))

        if depth >= 7 {
            let targetFirst = SCNVector3(cubeCenter.x, cubeCenter.y, cubeCenter.z)
            let moveTarget = SCNAction.move(to: targetFirst, duration: 1.2)
            moveTarget.timingMode = SCNActionTimingMode.easeInEaseOut

            let firstZoom = SCNAction.move(
                to: SCNVector3(targetFirst.x, targetFirst.y, Float(cubeSpan * 2.7)),
                duration: 1.2
            )
            firstZoom.timingMode = SCNActionTimingMode.easeInEaseOut

            let waitBetween = SCNAction.wait(duration: 0.6)

            if depth >= 10 {
                let targetSecond = outerCenter
                let targetThird = outer2Center
                let secondTarget = SCNAction.move(to: targetSecond, duration: 1.1)
                secondTarget.timingMode = SCNActionTimingMode.easeInEaseOut
                let thirdTarget = SCNAction.move(to: targetThird, duration: 1.1)
                thirdTarget.timingMode = SCNActionTimingMode.easeInEaseOut

                let secondZoom = SCNAction.move(
                    to: SCNVector3(targetSecond.x, targetSecond.y, Float(outerSpan * 2.3)),
                    duration: 1.1
                )
                secondZoom.timingMode = SCNActionTimingMode.easeInEaseOut
                let thirdZoom = SCNAction.move(
                    to: SCNVector3(targetThird.x, targetThird.y, Float(outer2Span * 2.6)),
                    duration: 1.1
                )
                thirdZoom.timingMode = SCNActionTimingMode.easeInEaseOut

                targetNode.runAction(
                    SCNAction.sequence([wait, moveTarget, waitBetween, secondTarget, waitBetween, thirdTarget])
                )
                cameraNode.runAction(
                    SCNAction.sequence([wait, firstZoom, waitBetween, secondZoom, waitBetween, thirdZoom])
                )
            } else {
                let targetSecond = outerCenter
                let secondTarget = SCNAction.move(to: targetSecond, duration: 1.1)
                secondTarget.timingMode = SCNActionTimingMode.easeInEaseOut
                let secondZoom = SCNAction.move(
                    to: SCNVector3(targetSecond.x, targetSecond.y, Float(outerSpan * 2.3)),
                    duration: 1.1
                )
                secondZoom.timingMode = SCNActionTimingMode.easeInEaseOut

                targetNode.runAction(SCNAction.sequence([wait, moveTarget, waitBetween, secondTarget]))
                cameraNode.runAction(SCNAction.sequence([wait, firstZoom, waitBetween, secondZoom]))
            }
        } else {
            let zoomOut = SCNAction.move(
                to: SCNVector3(0, 0, Float(fullSpan * 2.7)),
                duration: 1.2
            )
            zoomOut.timingMode = SCNActionTimingMode.easeInEaseOut
            cameraNode.runAction(SCNAction.sequence([wait, zoomOut]))
        }
        return cameraNode
    }

    private struct BlockExtent {
        let x: Int
        let y: Int
        let z: Int
    }

    private static func extentForDepth(_ depth: Int, extent: Int) -> BlockExtent {
        let safeExtent = max(extent, 1)
        if depth <= 1 {
            return BlockExtent(x: safeExtent, y: 1, z: 1)
        }
        if depth == 2 {
            return BlockExtent(x: safeExtent, y: safeExtent, z: 1)
        }
        if depth == 3 {
            return BlockExtent(x: safeExtent, y: safeExtent, z: safeExtent)
        }
        let phase = ((depth - 1) % 3) + 1
        let sub = Self.extentForDepth(depth - 3, extent: extent)
        let x = safeExtent * sub.x
        let y = (phase >= 2 ? safeExtent * sub.y : sub.y)
        let z = (phase == 3 ? safeExtent * sub.z : sub.z)
        return BlockExtent(x: x, y: y, z: z)
    }

    private static func placeBlocks(
        depth: Int,
        origin: SCNVector3,
        step: CGFloat,
        groupSpacing: CGFloat,
        extent: Int,
        box: SCNBox,
        materials: [SCNMaterial],
        container: SCNNode
    ) {
        let safeExtent = max(extent, 1)
        if depth <= 3 {
            let zRange = depth == 3 ? 0..<safeExtent : 0..<1
            let yRange = depth >= 2 ? 0..<safeExtent : 0..<1
            let xRange = 0..<safeExtent

            for z in zRange {
                for y in yRange {
                    for x in xRange {
                        let node = SCNNode(geometry: box)
                        node.geometry?.materials = [materials[Self.tintIndex(x: x, y: y, z: z, extent: safeExtent)]]
                        node.position = SCNVector3(
                            origin.x + Float(CGFloat(x) * step),
                            origin.y + Float(CGFloat(y) * step),
                            origin.z + Float(CGFloat(z) * step)
                        )
                        container.addChildNode(node)
                    }
                }
            }
            return
        }

        let phase = ((depth - 1) % 3) + 1
        let subExtent = Self.extentForDepth(depth - 3, extent: extent)
        let subSizeX = CGFloat(subExtent.x) * step + groupSpacing
        let subSizeY = CGFloat(subExtent.y) * step + groupSpacing
        let subSizeZ = CGFloat(subExtent.z) * step + groupSpacing

        let zCount = phase == 3 ? safeExtent : 1
        let yCount = phase >= 2 ? safeExtent : 1
        let xCount = safeExtent

        for z in 0..<zCount {
            for y in 0..<yCount {
                for x in 0..<xCount {
                    let offset = SCNVector3(
                        Float(CGFloat(x) * subSizeX),
                        Float(CGFloat(y) * subSizeY),
                        Float(CGFloat(z) * subSizeZ)
                    )
                    Self.placeBlocks(
                        depth: depth - 3,
                        origin: SCNVector3(origin.x + offset.x, origin.y + offset.y, origin.z + offset.z),
                        step: step,
                        groupSpacing: groupSpacing,
                        extent: extent,
                        box: box,
                        materials: materials,
                        container: container
                    )
                }
            }
        }
    }
}

private extension UIColor {
    func adjustedBrightness(factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }
        return UIColor(hue: hue, saturation: saturation, brightness: min(max(brightness * factor, 0.05), 1.0), alpha: alpha)
    }
}

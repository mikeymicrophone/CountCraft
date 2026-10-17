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

    @State private var allowsUserControl = false
    @State private var cameraControlTask: Task<Void, Never>?
    @State private var sceneBundle: SceneBundle?

    var body: some View {
        Group {
            if let sceneBundle {
                SceneKitContainerView(
                    scene: sceneBundle.scene,
                    pointOfView: sceneBundle.cameraNode,
                    allowsCameraControl: allowsUserControl
                )
            } else {
                Color.clear
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            if sceneBundle == nil {
                rebuildScene()
            } else {
                scheduleCameraControlIfNeeded()
            }
        }
        .onDisappear {
            cameraControlTask?.cancel()
            cameraControlTask = nil
        }
        .onChange(of: base) { _, _ in
            rebuildScene()
        }
        .onChange(of: depth) { _, _ in
            rebuildScene()
        }
        .onChange(of: color) { _, _ in
            rebuildScene()
        }
    }

    private struct SceneBundle {
        let scene: SCNScene
        let cameraNode: SCNNode
    }

    private static func buildScene(base: Int, depth: Int, color: Color) -> SceneBundle {
        let clampedDepth = min(max(depth, 1), 12)
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
        let boxes = Self.tintedBoxes(size: cubeSize, materials: materials)

        let usesAnimatedScene = (4...12).contains(clampedDepth)
        let cameraNode: SCNNode
        if usesAnimatedScene {
            cameraNode = Self.buildAnimatedExponentScene(
                depth: clampedDepth,
                extent: extent,
                cubeSize: cubeSize,
                step: step,
                spacing: spacing,
                boxes: boxes,
                color: color,
                container: container,
                root: root
            )
        } else {
            let rawBlocks = SCNNode()
            Self.placeBlocks(
                depth: clampedDepth,
                step: step,
                extent: extent,
                boxes: boxes,
                container: rawBlocks
            )
            container.addChildNode(rawBlocks.flattenedClone())
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

        let phase = ((clampedDepth - 1) % 3) + 1
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
        cameraControlTask?.cancel()
        cameraControlTask = nil
        let clampedDepth = min(max(depth, 1), 12)
        guard clampedDepth >= 10 else { return }
        cameraControlTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(5.6))
            guard !Task.isCancelled else { return }
            allowsUserControl = true
        }
    }

    private func rebuildScene() {
        let clampedDepth = min(max(depth, 1), 12)
        sceneBundle = Self.buildScene(base: base, depth: clampedDepth, color: color)
        let startsInteractive = (4...9).contains(clampedDepth)
        allowsUserControl = startsInteractive
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

    private static func tintedBoxes(size: CGFloat, materials: [SCNMaterial]) -> [SCNBox] {
        materials.map { material in
            let box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
            box.materials = [material]
            return box
        }
    }

    private static func groupMaterial(color: Color) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color).withAlphaComponent(0.85)
        material.lightingModel = .lambert
        material.writesToDepthBuffer = true
        material.readsFromDepthBuffer = true
        material.transparencyMode = .singleLayer
        return material
    }

    private static func tintFactor(index: Int, count: Int) -> CGFloat {
        guard count > 1 else { return 1.0 }
        let ratio = CGFloat(index) / CGFloat(count - 1)
        return 0.7 + (ratio * 0.4)
    }

    private static func buildAnimatedExponentScene(
        depth: Int,
        extent: Int,
        cubeSize: CGFloat,
        step: CGFloat,
        spacing: CGFloat,
        boxes: [SCNBox],
        color: Color,
        container: SCNNode,
        root: SCNNode
    ) -> SCNNode {
        let rawDetail = SCNNode()
        Self.placeBlocks(
            depth: 3,
            step: step,
            extent: extent,
            boxes: boxes,
            container: rawDetail
        )
        let detailBounds = rawDetail.boundingBox
        let detailMin = detailBounds.min
        let detailMax = detailBounds.max
        let detailCenter = SCNVector3(
            (detailMin.x + detailMax.x) / 2,
            (detailMin.y + detailMax.y) / 2,
            (detailMin.z + detailMax.z) / 2
        )
        let detailContainer = rawDetail.flattenedClone()
        detailContainer.position = SCNVector3(-detailCenter.x, -detailCenter.y, -detailCenter.z)
        container.addChildNode(detailContainer)

        let groupGap = spacing * 4
        let groupSpan = CGFloat(extent - 1) * step + cubeSize
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

        let groupBox = SCNBox(width: groupSpan, height: groupSpan, length: groupSpan, chamferRadius: 0)
        groupBox.materials = [Self.groupMaterial(color: color)]

        let rawGroups = SCNNode()
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
                    rawGroups.addChildNode(node)
                }
            }
        }
        let groupsContainer = rawGroups.flattenedClone()
        groupsContainer.renderingOrder = 10
        container.addChildNode(groupsContainer)

        var outerSpan: CGFloat = cubeSpan
        var outerCenter = cubeCenter

        if depth >= 7 {
            let outerBox = SCNBox(
                width: cubeSpan,
                height: cubeSpan,
                length: cubeSpan,
                chamferRadius: 0
            )
            outerBox.materials = [Self.groupMaterial(color: color)]

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

            let rawOuter = SCNNode()
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
                        rawOuter.addChildNode(node)
                    }
                }
            }
            let outerContainer = rawOuter.flattenedClone()
            outerContainer.renderingOrder = 20
            outerContainer.opacity = 0
            let outerFade = SCNAction.sequence([SCNAction.wait(duration: 1.8), SCNAction.fadeIn(duration: 1.0)])
            outerContainer.runAction(outerFade)
            container.addChildNode(outerContainer)
        }

        var outer2Span = outerSpan
        var outer2Center = outerCenter

        if depth >= 10 {
            let outer2Box = SCNBox(
                width: outerSpan,
                height: outerSpan,
                length: outerSpan,
                chamferRadius: 0
            )
            outer2Box.materials = [Self.groupMaterial(color: color)]

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

            let rawOuter2 = SCNNode()
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
                        rawOuter2.addChildNode(node)
                    }
                }
            }
            let outer2Container = rawOuter2.flattenedClone()
            outer2Container.renderingOrder = 30
            outer2Container.opacity = 0
            let outer2Fade = SCNAction.sequence([SCNAction.wait(duration: 2.6), SCNAction.fadeIn(duration: 1.0)])
            outer2Container.runAction(outer2Fade)
            container.addChildNode(outer2Container)
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

    private static func placeBlocks(
        depth: Int,
        step: CGFloat,
        extent: Int,
        boxes: [SCNBox],
        container: SCNNode
    ) {
        let safeExtent = max(extent, 1)
        let zRange = depth == 3 ? 0..<safeExtent : 0..<1
        let yRange = depth >= 2 ? 0..<safeExtent : 0..<1
        let xRange = 0..<safeExtent

        for z in zRange {
            for y in yRange {
                for x in xRange {
                    let box = boxes[Self.tintIndex(x: x, y: y, z: z, extent: safeExtent)]
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(
                        Float(CGFloat(x) * step),
                        Float(CGFloat(y) * step),
                        Float(CGFloat(z) * step)
                    )
                    container.addChildNode(node)
                }
            }
        }
    }
}

private struct SceneKitContainerView: UIViewRepresentable {
    let scene: SCNScene
    let pointOfView: SCNNode
    let allowsCameraControl: Bool

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.autoenablesDefaultLighting = true
        view.rendersContinuously = false
        view.antialiasingMode = .multisampling2X
        view.scene = scene
        view.pointOfView = pointOfView
        view.allowsCameraControl = allowsCameraControl
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if uiView.scene !== scene {
            uiView.scene = scene
            uiView.pointOfView = pointOfView
        } else if uiView.pointOfView !== pointOfView {
            uiView.pointOfView = pointOfView
        }
        if uiView.allowsCameraControl != allowsCameraControl {
            uiView.allowsCameraControl = allowsCameraControl
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

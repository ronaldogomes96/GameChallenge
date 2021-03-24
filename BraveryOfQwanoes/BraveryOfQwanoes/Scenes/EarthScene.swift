//
//  EarthScene.swift
//  BraveryOfQwanoes
//
//  Created by Ronaldo Gomes on 12/03/21.
//

import Foundation
import GameplayKit
import SpriteKit

class EarthScene: SKScene {

    lazy var velocity: Double = {
        return 50.0
    }()
    var background = Background(name: "rain")
    var character = CharacterBoat(characterName: "qwanoes_happy")
    var jsonNames = ["Introduction", "PartOne", "PartTwo", "PartThree", "PartFour", "PartFive"]
    var dialog = Dialog(historyPart: "Introduction")
    var dialogNodes = [SKLabelNode]()
    var firstPuzzle = FirstPuzzle()
    
    var puzzleOnScreen: Bool {
        dialogNodes.count == 1
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        let userTap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(userTap)

        setupNodePosition()
        setActualDialogNodes()
        setupDialogNodePosition()
        setUpCharacter(position: 0.0)
    }
    
    func setupNodePosition() {
        guard let backgroundComponent = background.component(ofType: DynamicBackgroundComponent.self)?.backgroundNode else {return}
        backgroundComponent.size.width = self.size.width * 2
        backgroundComponent.size.height = self.size.height
        backgroundComponent.position = CGPoint(x: backgroundComponent.size.width/2, y: self.frame.midY)
    
        let duration = Double(backgroundComponent.size.width/2)/velocity // tem haver com física tempo = espaço/velocidade
        let moveFloorAction = SKAction.moveBy(x: -backgroundComponent.size.width/2, y: 0, duration: duration)
        let resetXAction = SKAction.moveBy(x: backgroundComponent.size.width/2, y: 0, duration: 0)
        let sequenceActions = SKAction.sequence([moveFloorAction, resetXAction])
        let repeatAction = SKAction.repeatForever(sequenceActions)
        backgroundComponent.run(repeatAction)
        
        self.addChild(backgroundComponent)
    }
    
    func setUpCharacter(position: Double) {
        self.scene?.childNode(withName: "barco")?.removeFromParent()
        guard let characterComponent = character.component(ofType: PlayerControlComponent.self)?.playerNode else {return}
        characterComponent.size.width = 280
        characterComponent.size.height = 280
        characterComponent.position = CGPoint(x: self.frame.midX - characterComponent.size.width/3, y: self.frame.midY - self.size.height/4)
        characterComponent.name = "barco"//characterComponent.size.height/2
        characterComponent.removeAllActions()

        if puzzleOnScreen {
//            let rotate = SKAction.rotate(byAngle: CGFloat(position), duration: 0)
//            //SKAction.rot
//            let sequence = SKAction.sequence([rotate])
//            //let repeatAction = SKAction.repeat(sequence, count: <#T##Int#>)
//            characterComponent.run(sequence)
//            self.addChild(characterComponent)
            //let rotate = SKAction.rotate(toAngle: CGFloat(position), duration: 0)
            characterComponent.zRotation = CGFloat(position)
            self.addChild(characterComponent)
        } else {
            //let duration = 2
            let rotateX = SKAction.rotate(byAngle: CGFloat(0.2), duration: 1.2)
            let rotateY = SKAction.rotate(byAngle: CGFloat(-0.2), duration: 1.2)
            let sequence = SKAction.sequence([rotateX,rotateY])
            let repeatAction = SKAction.repeatForever(sequence)
            
            characterComponent.run(repeatAction)
            self.addChild(characterComponent)
        }
    }

    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        
        // É quando o puzzle não esta na tela
        if !puzzleOnScreen {
            dialogNodes.removeFirst()
            setupDialogNodePosition()
        }

    }

    func setupDialogNodePosition() {
        //Caso seja o ultimo node, reinicia o dialogo e uma nova lista de nodes
        if dialogNodes.isEmpty {
            jsonNames.removeFirst()
            dialog = Dialog(historyPart: jsonNames[0])
            setActualDialogNodes()
        }
        
        self.scene?.childNode(withName: "dialog")?.removeFromParent()
        let node = dialogNodes[0]
        node.name = "dialog"
        node.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(node)
    }
    
    func setActualDialogNodes() {
        guard let dialogNodes = dialog.component(ofType: DialogSpriteComponent.self)?.spritesNodes,
              let puzzleNodes = dialog.component(ofType: DialogSpriteComponent.self)?.spritePuzzleNode else {
            fatalError()
        }
        self.dialogNodes = dialogNodes
        self.dialogNodes.append(puzzleNodes)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if puzzleOnScreen {
            firstPuzzle.component(ofType: SensorialComponent.self)?.isPuzzle = true
            if firstPuzzle.component(ofType: SensorialComponent.self)!.isPuzzleEnd {
               //print("terminou")
                dialogNodes.removeFirst()
                setupDialogNodePosition()
            } else {
                let heading = firstPuzzle.component(ofType: SensorialComponent.self)!.position
                setUpCharacter(position: heading)
            }
        }
    }
    
}

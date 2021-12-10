//
//  ViewController.swift
//  trySelfDrawing
//
//  Created by ati chetsurakul on 9/12/21.
//

import UIKit
import CoreData
import PencilKit
class ViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var drawingInFormDataArray = [DrawingInFormData]()

    @IBOutlet weak var canvasView: PKCanvasView!
    var toolPicker = PKToolPicker()
    static let canvasOverscrollHeight: CGFloat = 500
    var drawing = PKDrawing()
    static let canvasWidth: CGFloat = 768
    @IBOutlet weak var canVasView: PKCanvasView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.alwaysBounceVertical = true
        loadDrawing()
        canvasView.drawing = drawing
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        canvasView.becomeFirstResponder()
        updateLayout(for: toolPicker)
        // Do any additional setup after loading the view.
    }
    
    

    
    @IBAction func ItemSavePressed(_ sender: UIBarButtonItem) {
        saveDataModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / ViewController.canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        // Scroll to the top.
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    func updateContentSizeForDrawing() {
        // Update the content size to match the drawing.
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        // Adjust the content size to always be bigger than the drawing height.
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + ViewController.canvasOverscrollHeight) * canvasView.zoomScale)
        } else {
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: ViewController.canvasWidth * canvasView.zoomScale, height: contentHeight)
    }

}

extension ViewController: PKCanvasViewDelegate {
    
}
extension ViewController:PKToolPickerObserver {
    
    
    func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        // If the tool picker is floating over the canvas, it also contains
        // undo and redo buttons.
        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
            navigationItem.leftBarButtonItems = []
        }
        
        // Otherwise, the bottom of the canvas should be inset to the top of the
        // tool picker, and the tool picker no longer displays its own undo and
        // redo buttons.
        else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
        }
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
    
}


extension ViewController {
    func saveDataModel() {
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(self.canvasView.drawing)
                let newDrawingInFormData = DrawingInFormData(context: self.context)
                newDrawingInFormData.drawed = data
                self.drawingInFormDataArray.append(newDrawingInFormData)
                 try self.context.save()
            } catch {
                print("Could not save data model: %s", error)
            }
    }
    
    
    func loadDrawing() {
        let request : NSFetchRequest<DrawingInFormData> = DrawingInFormData.fetchRequest()
        var decodedDrawing = PKDrawing()
            do{
                self.drawingInFormDataArray = try self.context.fetch(request)
                let decoder = PropertyListDecoder()
                decodedDrawing =  try decoder.decode(PKDrawing.self, from: self.drawingInFormDataArray[self.drawingInFormDataArray.count - 1].drawed!)
                self.drawing = decodedDrawing
            } catch {
                print(error)
            }
    }
}

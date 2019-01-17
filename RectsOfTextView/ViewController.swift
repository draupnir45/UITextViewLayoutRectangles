//
//  ViewController.swift
//  RectsOfTextView
//
//  Created by 박종찬 on 17/01/2019.
//  Copyright © 2019 박종찬. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let textView = TextViewWithNoPopMenu()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Those Rects"
    
    self.navigationController?.navigationBar.barTintColor = .white
    
    self.view.addSubview(textView)
    self.textView.frame = self.view.bounds
    self.textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
    self.textView.textContainerInset = UIEdgeInsets.init(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    self.textView.isEditable = false
    self.textView.allowsEditingTextAttributes = false
    self.setDummyText()
    
    let showRects = UIMenuItem.init(title: "Show Rects", action: #selector(self.showRectsMenus(_:)))
    UIMenuController.shared.menuItems = [showRects]
  }
  
  func setDummyText() {
    let dummyText =
    """
    Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

    Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.

    Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.

    Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur?

    Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?

    At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.
    """
    self.textView.text = dummyText
  }
  
  @IBAction func showRectsMenus(_ sender: Any) {
    
    let actions = [
      UIAlertAction(title: "boundingRect", style: UIAlertAction.Style.default, handler: { _ in
        let rect = self.textView.layoutManager.boundingRect(forGlyphRange: self.textView.selectedRange,
                                                            in: self.textView.textContainer)
        self.showRects([rect.applying(CGAffineTransform.init(translationX: 16.0, y: 16.0))])
      }),
      UIAlertAction(title: "enumerateEnclosingRects", style: .default, handler: { _ in
        var rects: [CGRect] = []
        self.textView.layoutManager.enumerateEnclosingRects(forGlyphRange: self.textView.selectedRange,
                                                            withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                                                            in: self.textView.textContainer, using: { (rect, _) in
                                                              rects.append(rect.applying(CGAffineTransform.init(translationX: 16.0, y: 16.0)))
        })
        self.showRects(rects)
      }),
      
      UIAlertAction(title: "enumerateLineFragments", style: .default, handler: { _ in
        var rects: [CGRect] = []
        self.textView.layoutManager.enumerateLineFragments(forGlyphRange: self.textView.selectedRange, using: { (rect1, rect2, _, _, _) in
          rects.append(rect2.applying(CGAffineTransform.init(translationX: 16.0, y: 16.0)))
        })
        self.showRects(rects)
      }),
      UIAlertAction(title: "selectionRects", style: .default, handler: { _ in
        if let textRange = self.textView.selectedRange.toTextRange(textInput: self.textView) {
          let rects: [CGRect] = self.textView.selectionRects(for: textRange).map { $0.rect }
          self.showRects(rects)
        }
      }),
      UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }),
      ]
    
    self.alert(title: "Which Rect?", actions: actions, preferredStyle: .alert)
    
  }
  
  var showingRectViews: [UIView] = []
  
  func showRects(_ rects: [CGRect]) {
    
    self.showingRectViews.forEach { $0.removeFromSuperview() }
    rects.forEach { rect in
      let rectView = UIView(frame: rect)
      rectView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
      rectView.layer.borderColor = UIColor.black.cgColor
      rectView.layer.borderWidth = 0.5
      self.textView.addSubview(rectView)
      self.showingRectViews.append(rectView)
    }
  }
  
}

class TextViewWithNoPopMenu: UITextView {
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return false
  }
}

extension UIViewController {
  func alert(title: String,
             message: String? = nil,
             actions: [UIAlertAction],
             
             preferredStyle: UIAlertController.Style,
             completion: (() -> Void)? = nil) {
    let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    actions.forEach { alert.addAction($0) }
    self.present(alert, animated: true, completion: completion)
  }
}

extension NSRange {
  func toTextRange(textInput: UITextInput) -> UITextRange? {
    if let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location),
      let rangeEnd = textInput.position(from: rangeStart, offset: length) {
      return textInput.textRange(from: rangeStart, to: rangeEnd)
    }
    return nil
  }
}

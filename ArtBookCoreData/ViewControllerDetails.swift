//
//  ViewControllerDetails.swift
//  ArtBookCoreData
//
//  Created by ece on 23.12.2021.
//

import UIKit
import CoreData

class ViewControllerDetails: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var artistField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintigs")
            //filtreleme islemi
            let idStrings = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idStrings!)
            fetchRequest.returnsObjectsAsFaults  = false
            do {
              let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String{
                            nameField.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistField.text = artist
                        }
                            
                    }
                }
            }catch {
                print("error")
            }
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }

    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        //VERİ KAYDETME
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintigs", into: context)
        
        // Atributes
        //string
        newPainting.setValue(UUID(), forKey: "id")
        newPainting.setValue(nameField.text!, forKey: "name")
        newPainting.setValue(artistField.text!, forKey: "artist")
        
        //int
        if let year = Int(yearField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        //image
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
        }catch {
            print("image seve error")
        }
        //controllerlar arasında mesaj göndererek iletişim kurabilirsin
        NotificationCenter.default.post(name: NSNotification.Name("NewData"), object: nil)
        //butona bastıktan sonra önceki controllera gecme
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //klavyeyi bosluga basınca kapanması
    @IBAction func closeKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
}

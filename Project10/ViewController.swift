//
//  ViewController.swift
//  Project10
//
//  Created by Olibo moni on 11/02/2022.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    var leftButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        collectionView.backgroundColor = .black
        
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let decoder = JSONDecoder()
            do {
                people = try decoder.decode([Person].self, from: savedPeople)
            } catch {
                print("failed to load saved People")
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue cell")
        }
        let person = people[indexPath.item]
        
        cell.label.text = person.name
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.image.image = UIImage(contentsOfFile: path.path)
        cell.image.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.image.layer.borderWidth = 2
        cell.image.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
//            present(picker, animated: true)
//            picker.allowsEditing = true
//            picker.delegate = self
//            return
        }
        
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        guard let image = info[.editedImage] as? UIImage else {return}
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
        })

            //present(ac, animated: true)
    
        
        
        let ac1 = UIAlertController(title: "Delete or Rename", message: nil, preferredStyle: .alert)
        ac1.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.people.remove(at: indexPath.item)
            self.collectionView.reloadData()
        }))
        ac1.addAction(UIAlertAction(title: "Rename", style: .default, handler: { action in
            self.present(ac, animated: true)
        }))
        ac1.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac1, animated: true)
        
   
    }
    
    func save(){
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(people){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("failed to save data")
        }
    }
    
}


//
//  ViewController.swift
//  HeroApp
//
//  Created by Inara Almagambetova on 28.11.2024.
//

import UIKit
import Alamofire
import Kingfisher

struct Hero: Decodable {
    let name: String
    let biography: Biography
    let powerstats: PowerStats
    let images: HeroImage

    struct Biography: Decodable {
        let fullName: String
        let placeOfBirth: String
        let alignment: String
    }

    struct PowerStats: Decodable {
        let intelligence: Int
        let strength: Int
        let speed: Int
        let durability: Int
        let power: Int
        let combat: Int
    }

    struct HeroImage: Decodable {
        let sm: String
    }
}


class ViewController: UIViewController {

    @IBOutlet private weak var heroName: UILabel!
    @IBOutlet private weak var heroDescription: UILabel!
    @IBOutlet private weak var heroImage: UIImageView!
    @IBOutlet private weak var heroIntelligenceLabel: UILabel!
    @IBOutlet private weak var heroStrengthLabel: UILabel!
    @IBOutlet private weak var heroSpeedLabel: UILabel!
    @IBOutlet private weak var heroDurabilityLabel: UILabel!
    @IBOutlet private weak var heroPowerLabel: UILabel!
    @IBOutlet private weak var heroCombatLabel: UILabel!
    @IBOutlet private weak var placeOfBirthLabel: UILabel!
    @IBOutlet private weak var alignmentLabel: UILabel!
    
    private let api = "https://akabab.github.io/superhero-api/api/all.json"
    private var heroes: [Hero] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHero()
    }

    
    @IBAction private func didTapHero(_ sender: Any) {
        if heroes.isEmpty {
            print("Hero list is empty. Fetching heroes again...")
            fetchHero()
        } else {
            guard let randomHero = heroes.randomElement() else {
                print("Failed to select a random hero.")
                return
            }
            animateTransition(to: randomHero)
        }
    }
    
    private func animateTransition(to hero: Hero) {
        UIView.transition(with: self.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.configure(hero: hero)
        }, completion: nil)
    }

    private func fetchHero() {
        AF.request(api).responseDecodable(of: [Hero].self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let heroes):
                self.heroes = heroes
                print("Heroes fetched successfully: \(heroes.count)")
                if let firstHero = heroes.first {
                    self.configure(hero: firstHero)
                }
            case .failure(let error):
                print("Error fetching heroes: \(error.localizedDescription)")
            }
        }
    }

    private func configure(hero: Hero) {
        heroName.text = hero.name
        heroDescription.text = hero.biography.fullName.isEmpty ? "Unknown Hero" : hero.biography.fullName
        
        if let imageUrl = URL(string: hero.images.sm) {
            heroImage.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "person.fill"))
        } else {
            heroImage.image = UIImage(systemName: "person.fill")
        }
        
        heroIntelligenceLabel.text = "Intelligence: \(hero.powerstats.intelligence)"
        heroStrengthLabel.text = "Strength: \(hero.powerstats.strength)"
        heroSpeedLabel.text = "Speed: \(hero.powerstats.speed)"
        heroDurabilityLabel.text = "Durability: \(hero.powerstats.durability)"
        heroPowerLabel.text = "Power: \(hero.powerstats.power)"
        heroCombatLabel.text = "Combat: \(hero.powerstats.combat)"
        
        placeOfBirthLabel.text = "Place of Birth: \(hero.biography.placeOfBirth.isEmpty ? "Unknown" : hero.biography.placeOfBirth)"
        alignmentLabel.text = "Alignment: \(hero.biography.alignment.capitalized)"
        
        print("Configured hero: \(hero.name)")
    }
}

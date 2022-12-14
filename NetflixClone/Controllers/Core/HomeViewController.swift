//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Maks Kokos on 29.10.2022.
//

import UIKit

enum Sections: Int {
    case TrendingMovies
    case TrendingTvs
    case PopularMovies
    case UpcomigMovies
    case TopRatedMovies
}

class HomeViewController: UIViewController {
    
    private var randomTrandingMovie: Movie?
    private var headerView: HeroHeaderUIView?
    
    private let sectionsTitles = ["Trending Movies", "Trending Tv", "Popular", "Upcoming Movies", "Top Rated"]
    
    private let homeMainTable: UITableView = {
        let table = UITableView(frame:  .zero,style: .grouped)
        table.backgroundColor = .systemBackground
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.cellId)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(homeMainTable)
            
        homeMainTable.delegate = self
        homeMainTable.dataSource = self
        
        configureNavBar()
        
        headerView = HeroHeaderUIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeMainTable.tableHeaderView = headerView
        
        configureHeroHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeMainTable.frame = view.bounds
    }
    
    private func configureHeroHeaderView() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            switch result {
            case .success(let movies):
                let selectedMovie = movies.randomElement()
                self?.randomTrandingMovie = selectedMovie
                self?.headerView?.configureHeaderView(path: selectedMovie?.poster_path ?? "")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureNavBar() {
        var image = UIImage(named: "flogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .plain, target: self, action: nil)
        ]
        
        navigationController?.navigationBar.tintColor = .systemRed
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionsTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.cellId, for: indexPath) as? CollectionViewTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self 
        
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TrendingTvs.rawValue:
            APICaller.shared.getTrendingTvs { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        case Sections.PopularMovies.rawValue:
            APICaller.shared.getPopularMovies { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.UpcomigMovies.rawValue:
            APICaller.shared.getUpcomingMovies { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TopRatedMovies.rawValue:
            APICaller.shared.getTopRatedMovies { result in
                switch result {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        default:
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .label
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionsTitles[section]
    }
    
    // hiding navBar when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
}

extension HomeViewController: CollectionViewTableViewCellDelegate {
    
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: MoviePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = MoviePreviewViewController()
            vc.configure(with: viewModel)
//            self?.navigationController?.pushViewController(vc, animated: true)
            self?.navigationController?.showDetailViewController(vc, sender: nil)
        }

    }
    
}

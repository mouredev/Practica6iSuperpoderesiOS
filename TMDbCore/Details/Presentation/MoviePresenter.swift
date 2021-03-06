//
//  MoviePresenter.swift
//  TMDbCore
//
//  Created by Guille Gonzalez on 08/10/2017.
//  Copyright © 2017 Guille Gonzalez. All rights reserved.
//

import RxSwift

final class MoviePresenter: DetailPresenter {
    private let detailNavigator: DetailNavigator
    private let repository: MovieRepositoryProtocol
    
    private let identifier: Int64
    private let disposeBag = DisposeBag()
    
    weak var view: DetailView?
    
    init(detailNavigator: DetailNavigator, repository: MovieRepositoryProtocol, identifier: Int64) {
        self.detailNavigator = detailNavigator
        self.repository = repository
        self.identifier = identifier
    }
    
    func didLoad() {
        view?.setLoading(true)
        
        repository.movie(withIdentifier: identifier)
            .map { [weak self] movie in
                self?.detailSections(for: movie) ?? []
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] sections in
                self?.view?.update(with: sections)
            }, onDisposed: { [weak self] in
                self?.view?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    func didSelect(item: PosterStripItem) {
        switch item.mediaType {
        case .movie:
            detailNavigator.navigateToMovie(withIdentifier: item.identifier)
        case .show:
            detailNavigator.navigateToShow(withIdentifier: item.identifier)
        case .person:
            detailNavigator.navigateToPerson(withIdentifier: item.identifier)
        }
    }
    
    private func detailSections(for movie: MovieDetail) -> [DetailSection] {
		var detailSections: [DetailSection] = [
			.header(DetailHeader(movie: movie))
		]

		if let overview = movie.overview {
			detailSections.append(.about(title: "Overview", detail: overview))
		}

		let items = movie.credits?.cast.map { PosterStripItem(castMember: $0) }

		if let items = items {
			detailSections.append(.posterStrip(title: "Cast", items: items))
		}

        return detailSections
    }
}

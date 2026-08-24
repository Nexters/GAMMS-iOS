//
//  NavigationBarHider.swift
//  GAMSS
//
//  Created by 이건준 on 8/24/26.
//

import SwiftUI

/// NavigationStack 기준으로
/// - 네비게이션 바: 항상 숨김
/// - 탭 바: 루트에서만 표시, push된 화면에서는 숨김
struct NavigationBarHider: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = HostViewController()
        controller.onAppear = { [weak coordinator = context.coordinator, weak controller] in
            guard let controller else { return }
            coordinator?.bind(from: controller)
        }
        context.coordinator.bind(from: controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.bind(from: uiViewController)
    }

    final class HostViewController: UIViewController {
        var onAppear: (() -> Void)?

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            onAppear?()
        }
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate {
        private weak var navigationController: UINavigationController?
        private weak var originalDelegate: UINavigationControllerDelegate?

        func bind(from controller: UIViewController) {
            DispatchQueue.main.async { [weak self, weak controller] in
                guard let self, let navigationController = controller?.navigationController else { return }

                if self.navigationController !== navigationController {
                    self.originalDelegate = navigationController.delegate
                    self.navigationController = navigationController
                    navigationController.delegate = self
                }

                self.applyChrome(for: navigationController)
            }
        }

        func navigationController(
            _ navigationController: UINavigationController,
            willShow viewController: UIViewController,
            animated: Bool
        ) {
            applyChrome(for: navigationController)
            originalDelegate?.navigationController?(
                navigationController,
                willShow: viewController,
                animated: animated
            )
        }

        func navigationController(
            _ navigationController: UINavigationController,
            didShow viewController: UIViewController,
            animated: Bool
        ) {
            applyChrome(for: navigationController)
            originalDelegate?.navigationController?(
                navigationController,
                didShow: viewController,
                animated: animated
            )
        }

        private func applyChrome(for navigationController: UINavigationController) {
            navigationController.setNavigationBarHidden(true, animated: false)

            let isRoot = navigationController.viewControllers.count <= 1
            navigationController.tabBarController?.tabBar.isHidden = !isRoot
        }
    }
}

//
//  NavigationBarHider.swift
//  GAMSS
//
//  Created by 이건준 on 8/24/26.
//

import SwiftUI

/// NavigationStack 안의 시스템 네비게이션 바를 항상 숨긴다.
/// 탭 바는 SwiftUI `.toolbar(.hidden, for: .tabBar)`로 처리해야 레이아웃이 전체 높이로 확장된다.
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

                self.hideNavigationBar(on: navigationController)
            }
        }

        func navigationController(
            _ navigationController: UINavigationController,
            willShow viewController: UIViewController,
            animated: Bool
        ) {
            hideNavigationBar(on: navigationController)
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
            hideNavigationBar(on: navigationController)
            originalDelegate?.navigationController?(
                navigationController,
                didShow: viewController,
                animated: animated
            )
        }

        private func hideNavigationBar(on navigationController: UINavigationController) {
            navigationController.setNavigationBarHidden(true, animated: false)
            // UIKit으로 탭바를 숨기면 하단 여백이 남을 수 있어, 탭바는 SwiftUI toolbar로만 제어한다.
            if navigationController.viewControllers.count <= 1 {
                navigationController.tabBarController?.tabBar.isHidden = false
            }
        }
    }
}

extension View {
    /// push된 화면에서 탭바를 숨기고 콘텐츠가 전체 높이를 쓰도록 한다.
    func hidesTabBar() -> some View {
        toolbar(.hidden, for: .tabBar)
    }
}

//
//  LoadingView.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/10/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import WebKit

class LoadingView: ZapicView {

    init(_ viewModel:ZapicViewModel) {
        super.init(viewModel, text: "Loading...")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

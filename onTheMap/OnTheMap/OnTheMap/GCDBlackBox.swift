//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Jordan  on 6/12/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

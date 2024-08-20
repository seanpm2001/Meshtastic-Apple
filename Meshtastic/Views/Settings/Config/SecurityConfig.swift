//
//  Security.swift
//  Meshtastic
//
// Copyright(c) Garth Vander Houwen 8/7/24.
//

import Foundation
import SwiftUI
import CoreData
import MeshtasticProtobufs
import OSLog

struct SecurityConfig: View {

	private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var bleManager: BLEManager
	@Environment(\.dismiss) private var goBack

	var node: NodeInfoEntity?

	@State var hasChanges = false
	@State var publicKey = ""
	@State var hasValidPublicKey: Bool = false
	@State var privateKey = ""
	@State var hasValidPrivateKey: Bool = false
	@State var adminKey = ""
	@State var hasValidAdminKey: Bool = true
	@State var isManaged = false
	@State var serialEnabled = false
	@State var debugLogApiEnabled = false
	@State var bluetoothLoggingEnabled = false
	@State var adminChannelEnabled = false

	var body: some View {
		VStack {
			Form {
				ConfigHeader(title: "Security", config: \.securityConfig, node: node, onAppear: setSecurityValues)

				Section(header: Text("Admin & Direct Message Keys")) {
					VStack(alignment: .leading) {
						Label("Public Key", systemImage: "key")
						SecureInput("Public Key", text: $publicKey, isValid: $hasValidPublicKey)
							.background(
								RoundedRectangle(cornerRadius: 10.0)
									.stroke(hasValidPublicKey ?	Color.clear : Color.red, lineWidth: 2.0)
							)
						Text("Sent out to other nodes on the mesh to allow them to compute a shared secret key.")
							.foregroundStyle(.secondary)
							.font(idiom == .phone ? .caption : .callout)
					}
					VStack(alignment: .leading) {
						Label("Private Key", systemImage: "key.fill")
						SecureInput("Private Key", text: $privateKey, isValid: $hasValidPrivateKey)
							.background(
								RoundedRectangle(cornerRadius: 10.0)
									.stroke(hasValidPrivateKey ? Color.clear : Color.red, lineWidth: 2.0)
							)
						Text("Used to create a shared key with a remote device.")
							.foregroundStyle(.secondary)
							.font(idiom == .phone ? .caption : .callout)
					}
					VStack(alignment: .leading) {
						Label("Admin Key", systemImage: "key.viewfinder")
						SecureInput("Admin Key", text: $adminKey, isValid: $hasValidAdminKey)
						Text("The public key authorized to send admin messages to this node.")
							.foregroundStyle(.secondary)
							.font(idiom == .phone ? .caption : .callout)
					}
				}
				Section(header: Text("Logs")) {
					Toggle(isOn: $bluetoothLoggingEnabled) {
						Label("Bluetooth Logs", systemImage: "dot.radiowaves.right")
						Text("View and export position-redacted device logs over Bluetooth")
						Link("View Logs", destination: URL(string: "meshtastic:///settings/debugLogs")!)
					}
					.toggleStyle(SwitchToggleStyle(tint: .accentColor))
				}
				Section(header: Text("Administration")) {
					if adminKey.length > 0 || adminChannelEnabled {
						Toggle(isOn: $isManaged) {
							Label("Managed Device", systemImage: "gearshape.arrow.triangle.2.circlepath")
							Text("Device is managed by a mesh administrator.")
						}
						.toggleStyle(SwitchToggleStyle(tint: .accentColor))
					}
					Toggle(isOn: $adminChannelEnabled) {
						Label("Legacy Administration", systemImage: "lock.slash")
						Text("Allow incoming device control over the insecure legacy admin channel.")
					}
					.toggleStyle(SwitchToggleStyle(tint: .accentColor))
				}
				Section(header: Text("Developer")) {
					Toggle(isOn: $serialEnabled) {
						Label("Serial Console", systemImage: "terminal")
						Text("Serial Console over the Stream API.")
					}
					.toggleStyle(SwitchToggleStyle(tint: .accentColor))
					if serialEnabled {
						Toggle(isOn: $debugLogApiEnabled) {
							Label("Serial Debug Logs", systemImage: "ant.fill")
							Text("Output live debug logging over serial.")
						}
						.toggleStyle(SwitchToggleStyle(tint: .accentColor))
					}
				}
			}
		}
		.scrollDismissesKeyboard(.immediately)
		.navigationTitle("Security Config")
		.navigationBarItems(trailing: ZStack {
			ConnectedDevice(
				bluetoothOn: bleManager.isSwitchedOn,
				deviceConnected: bleManager.connectedPeripheral != nil,
				name: "\(bleManager.connectedPeripheral?.shortName ?? "?")"
			)
		})
		.onChange(of: isManaged) {
			if $0 != node?.securityConfig?.isManaged { hasChanges = true }
		}
		.onChange(of: serialEnabled) {
			if $0 != node?.securityConfig?.serialEnabled { hasChanges = true }
		}
		.onChange(of: debugLogApiEnabled) {
			if $0 != node?.securityConfig?.debugLogApiEnabled { hasChanges = true }
		}
		.onChange(of: bluetoothLoggingEnabled) {
			if $0 != node?.securityConfig?.bluetoothLoggingEnabled { hasChanges = true }
		}
		.onChange(of: adminChannelEnabled) {
			if $0 != node?.securityConfig?.adminChannelEnabled { hasChanges = true }
		}
		.onChange(of: publicKey) { _ in
			let tempKey = Data(base64Encoded: publicKey) ?? Data()
			if tempKey.count == 32 {
				hasValidPublicKey = true
			} else {
				hasValidPublicKey = false
			}
			hasChanges = true
		}
		.onChange(of: privateKey) { _ in
			let tempKey = Data(base64Encoded: privateKey) ?? Data()
			if tempKey.count == 32 {
				hasValidPrivateKey = true
			} else {
				hasValidPrivateKey = false
			}
			hasChanges = true
		}
		.onChange(of: adminKey) { _ in
			let tempAdminKey = Data(base64Encoded: adminKey) ?? Data()
			if tempAdminKey.count == 0 || tempAdminKey.count == 32 {
				hasValidAdminKey = true
			} else {
				hasValidAdminKey = false
			}
			hasChanges = true
		}
		.onFirstAppear {
			// Need to request a Power config from the remote node before allowing changes
			if bleManager.connectedPeripheral != nil && node?.securityConfig == nil {
				let connectedNode = getNodeInfo(id: bleManager.connectedPeripheral?.num ?? 0, context: context)
				if node != nil && connectedNode != nil {
					_ = bleManager.requestSecurityConfig(fromUser: connectedNode!.user!, toUser: node!.user!, adminIndex: connectedNode?.myInfo?.adminIndex ?? 0)
				}
			}
		}

		SaveConfigButton(node: node, hasChanges: $hasChanges) {

			if !hasValidAdminKey || !hasValidPrivateKey || !hasValidAdminKey {
				return
			}

			guard let connectedNode = getNodeInfo(id: bleManager.connectedPeripheral.num, context: context),
				  let fromUser = connectedNode.user,
				  let toUser = node?.user else {
				return
			}

			var config = Config.SecurityConfig()
			config.publicKey = Data(base64Encoded: publicKey) ?? Data()
			config.privateKey = Data(base64Encoded: privateKey) ?? Data()
			config.adminKey = Data(base64Encoded: adminKey) ?? Data()
			config.isManaged = isManaged
			config.serialEnabled = serialEnabled
			config.debugLogApiEnabled = debugLogApiEnabled
			config.bluetoothLoggingEnabled = bluetoothLoggingEnabled
			config.adminChannelEnabled = adminChannelEnabled

			let adminMessageId = bleManager.saveSecurityConfig(
				config: config,
				fromUser: fromUser,
				toUser: toUser,
				adminIndex: connectedNode.myInfo?.adminIndex ?? 0
			)
			if adminMessageId > 0 {
				// Should show a saved successfully alert once I know that to be true
				// for now just disable the button after a successful save
				hasChanges = false
				goBack()
			}
		}
	}

	func setSecurityValues() {
		self.publicKey = node?.securityConfig?.publicKey?.base64EncodedString() ?? ""
		self.privateKey = node?.securityConfig?.privateKey?.base64EncodedString() ?? ""
		self.adminKey = node?.securityConfig?.adminKey?.base64EncodedString() ?? ""
		self.isManaged = node?.securityConfig?.isManaged ?? false
		self.serialEnabled = node?.securityConfig?.serialEnabled ?? false
		self.debugLogApiEnabled = node?.securityConfig?.debugLogApiEnabled ?? false
		self.bluetoothLoggingEnabled = node?.securityConfig?.bluetoothLoggingEnabled ?? false
		self.adminChannelEnabled = node?.securityConfig?.adminChannelEnabled ?? false
		self.hasChanges = false
	}
}

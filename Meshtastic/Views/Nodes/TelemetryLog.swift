//
//  TelemetryLog.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 7/7/22.
//
import SwiftUI

struct TelemetryLog: View {
	
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var bleManager: BLEManager
	
	var node: NodeInfoEntity

	var body: some View {
		
		VStack {
		
			List {
				
				
				ForEach(node.telemetries!.array as! [TelemetryEntity], id: \.self) { (tel: TelemetryEntity) in
					
					VStack {
						
						if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {

							
							if tel.metricsType == 0 {
								
								// Device Metrics
								HStack {
								
									Text("Device Metrics")
										.font(.title3)
									BatteryIcon(batteryLevel: tel.batteryLevel, font: .callout, color: .accentColor)
									
									if tel.batteryLevel == 0 {
										
										Text("Plugged In")
											.font(.callout)
											.foregroundColor(.gray)
										
									} else {
										
										Text("Battery Level: \(String(tel.batteryLevel))%")
											.font(.callout)
											.foregroundColor(.gray)
									}
									if tel.batteryLevel > 0 {
										
										Image(systemName: "bolt")
											.font(.callout)
											.foregroundColor(.accentColor)
											.symbolRenderingMode(.hierarchical)
										Text("Voltage: \(String(tel.voltage))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									Text("Channel Utilization: \(String(format: "%.2f", tel.channelUtilization))%")
										.foregroundColor(.gray)
										.font(.callout)
									
									Text("Airtime Utilization: \(String(format: "%.2f", tel.airUtilTx))%")
										.foregroundColor(.gray)
										.font(.callout)
									
									Image(systemName: "clock.badge.checkmark.fill")
											.font(.callout)
											.foregroundColor(.accentColor)
											.symbolRenderingMode(.hierarchical)
									Text("Time:")
										.foregroundColor(.gray)
										.font(.callout)
									DateTimeText(dateTime: tel.time)
										.foregroundColor(.gray)
										.font(.callout)
								}
								
							} else if tel.metricsType == 1 {
								
								// Environment Metrics
								HStack {
								
									Text("Environment Metrics")
										.font(.title3)
									
									let sensor = SensorTypes(rawValue: Int(node.telemetryConfig?.environmentSensorType ?? 0))
									
									let tempReadingType = (!(node.telemetryConfig?.environmentDisplayFahrenheit ?? true)) ? "°F" : "°C"
									
									if  sensor == SensorTypes.bme280 ||
										sensor == SensorTypes.bme680 ||
										sensor == SensorTypes.shtc3 ||
										sensor == SensorTypes.mcp9808 {
										
										Image(systemName: "thermometer")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Temperature: \(String(format: "%.2f", tel.temperature))\(tempReadingType)")
											.foregroundColor(.gray)
											.font(.callout)
									}
																		
									if  sensor == SensorTypes.bme280 ||
										sensor == SensorTypes.bme680 ||
										sensor == SensorTypes.shtc3 {
										
										Image(systemName: "humidity")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Relative Humidity: \(String(format: "%.2f", tel.relativeHumidity))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
									if  sensor == SensorTypes.bme280 ||
										sensor == SensorTypes.bme680 {
										
										Image(systemName: "barometer")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Barometric Pressure: \(String(format: "%.2f", tel.barometricPressure))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
									if sensor == SensorTypes.bme680 {
										
										Image(systemName: "aqi.medium")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Gas Resistance: \(String(format: "%.2f", tel.gasResistance))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
									if  sensor == SensorTypes.ina219 ||
										sensor == SensorTypes.ina260 {
										
										Image(systemName: "directcurrent")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Current: \(String(format: "%.2f", tel.current))")
											.foregroundColor(.gray)
											.font(.callout)
										
										Image(systemName: "bolt")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Voltage: \(String(format: "%.2f", tel.voltage))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
									Image(systemName: "clock.badge.checkmark.fill")
											.font(.callout)
											.foregroundColor(.accentColor)
											.symbolRenderingMode(.hierarchical)
									Text("Time:")
										.foregroundColor(.gray)
										.font(.callout)
									DateTimeText(dateTime: tel.time)
										.foregroundColor(.gray)
										.font(.callout)
									
								}
							}
							
						} else {
						
							if tel.metricsType == 0 {
								
								// Device Metrics
								HStack {
								
									Text("Device Metrics")
										.font(.title3)
									BatteryIcon(batteryLevel: tel.batteryLevel, font: .callout, color: .accentColor)
									
									if tel.batteryLevel == 0 {
										
										Text("Plugged In")
											.font(.callout)
											.foregroundColor(.gray)
										
									} else {
										
										Text("Battery Level: \(String(tel.batteryLevel))%")
											.font(.callout)
											.foregroundColor(.gray)
									}
									if tel.batteryLevel > 0 {
										
										Image(systemName: "bolt")
											.font(.callout)
											.foregroundColor(.accentColor)
											.symbolRenderingMode(.hierarchical)
										Text("Voltage: \(String(tel.voltage))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
								}
								HStack {
									
									Text("Channel Utilization: \(String(format: "%.2f", tel.channelUtilization))%")
										.foregroundColor(.gray)
										.font(.callout)
									
									Text("Airtime Utilization: \(String(format: "%.2f", tel.airUtilTx))%")
										.foregroundColor(.gray)
										.font(.callout)
									
									Image(systemName: "clock.badge.checkmark.fill")
										.font(.callout)
										.foregroundColor(.accentColor)
										.symbolRenderingMode(.hierarchical)
									Text("Time:")
										.foregroundColor(.gray)
										.font(.callout)
									DateTimeText(dateTime: tel.time)
										.foregroundColor(.gray)
										.font(.callout)
								}
							} else if tel.metricsType == 1 {
								
								// Environment Metrics
								let sensor = SensorTypes(rawValue: Int(node.telemetryConfig?.environmentSensorType ?? 0))
								
								let tempReadingType = (!(node.telemetryConfig?.environmentDisplayFahrenheit ?? true)) ? "°F" : "°C"
								
								HStack {
								
									Text("Environment Metrics")
										.font(.title3)
									
									if  sensor == SensorTypes.bme280 ||
										sensor == SensorTypes.bme680 ||
										sensor == SensorTypes.shtc3 ||
										sensor == SensorTypes.mcp9808 {
										
										Image(systemName: "thermometer")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Temperature: \(String(format: "%.2f", tel.temperature))\(tempReadingType)")
											.foregroundColor(.gray)
											.font(.callout)
									}
																		
									if  sensor == SensorTypes.bme280 ||
										sensor == SensorTypes.bme680 ||
										sensor == SensorTypes.shtc3 {
										
										Image(systemName: "humidity")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Relative Humidity: \(String(format: "%.2f", tel.relativeHumidity))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
									if  sensor == SensorTypes.ina219 ||
										sensor == SensorTypes.ina260 {
										
										Image(systemName: "directcurrent")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Current: \(String(format: "%.2f", tel.current))")
											.foregroundColor(.gray)
											.font(.callout)
										
										Image(systemName: "bolt")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Voltage: \(String(format: "%.2f", tel.voltage))")
											.foregroundColor(.gray)
											.font(.callout)
									}
								}
								HStack {
									
									if  sensor == SensorTypes.bme280 ||
										sensor == SensorTypes.bme680 {
										
										Image(systemName: "barometer")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Barometric Pressure: \(String(format: "%.2f", tel.barometricPressure))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
									if sensor == SensorTypes.bme680 {
										
										Image(systemName: "aqi.medium")
												.font(.callout)
												.foregroundColor(.accentColor)
												.symbolRenderingMode(.hierarchical)
										Text("Gas Resistance: \(String(format: "%.2f", tel.gasResistance))")
											.foregroundColor(.gray)
											.font(.callout)
									}
									
									Image(systemName: "clock.badge.checkmark.fill")
											.font(.callout)
											.foregroundColor(.accentColor)
											.symbolRenderingMode(.hierarchical)
									Text("Time:")
										.foregroundColor(.gray)
										.font(.callout)
									DateTimeText(dateTime: tel.time)
										.foregroundColor(.gray)
										.font(.callout)
									
								}
							}
						}
					}
				}
			}
		}
		.padding()
		.navigationTitle("Telemetry Log \(node.telemetries?.count ?? 0) Readings")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarItems(trailing:

			ZStack {

			ConnectedDevice(bluetoothOn: bleManager.isSwitchedOn, deviceConnected: bleManager.connectedPeripheral != nil, name: (bleManager.connectedPeripheral != nil) ? bleManager.connectedPeripheral.shortName : "????")
		})
		.onAppear {

			self.bleManager.context = context
		}
	}
}

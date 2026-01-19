/**
 * Example: Type-Safe Service Access with HomeAtlas
 * 
 * This example demonstrates how User Story 4 enables compile-time type safety
 * and autocomplete for HomeKit services in TypeScript/React Native.
 */

import HomeAtlas, { 
  isServiceType,
  LightbulbService, 
  ThermostatService,
  ServiceTypes,
  CharacteristicTypes
} from 'react-native-homeatlas';

// Example 1: Type-safe lightbulb control
async function controlLightbulb() {
  const homes = await HomeAtlas.getHomes();
  const accessories = homes[0].accessories;
  
  // Find a lightbulb accessory
  const lightbulbAccessory = accessories.find(
    acc => acc.category === 'lightbulb'
  );
  
  if (!lightbulbAccessory) {
    console.log('No lightbulb found');
    return;
  }
  
  // Find the lightbulb service
  const service = lightbulbAccessory.services.find(
    s => s.type === ServiceTypes.LIGHTBULB
  );
  
  if (!service) {
    console.log('No lightbulb service found');
    return;
  }
  
  // Type guard with runtime validation - checks service.type matches the UUID
  if (isServiceType<LightbulbService>(service, ServiceTypes.LIGHTBULB)) {
    // TypeScript now knows about lightbulb-specific characteristics
    // and provides autocomplete for: powerstate, brightness, hue, saturation, colortemperature
    
    // Read current state (type-safe boolean)
    const isOn: boolean = service.powerstate.value;
    console.log(`Light is currently: ${isOn ? 'ON' : 'OFF'}`);
    
    // Optional characteristics have proper types
    const brightness: number | undefined = service.brightness?.value;
    if (brightness !== undefined) {
      console.log(`Brightness: ${brightness}%`);
    }
    
    // Write new values with type safety
    await HomeAtlas.writeCharacteristic(
      lightbulbAccessory.id,
      ServiceTypes.LIGHTBULB,
      CharacteristicTypes.POWER_STATE,
      !isOn // TypeScript ensures this is boolean
    );
    
    // Set brightness if available
    if (service.brightness) {
      await HomeAtlas.writeCharacteristic(
        lightbulbAccessory.id,
        ServiceTypes.LIGHTBULB,
        CharacteristicTypes.BRIGHTNESS,
        75 // TypeScript ensures this is number
      );
    }
  }
}

// Example 2: Type-safe thermostat control
async function controlThermostat() {
  const homes = await HomeAtlas.getHomes();
  const accessories = homes[0].accessories;
  
  // Find a thermostat accessory
  const thermostatAccessory = accessories.find(
    acc => acc.category === 'thermostat'
  );
  
  if (!thermostatAccessory) {
    console.log('No thermostat found');
    return;
  }
  
  // Find the thermostat service
  const service = thermostatAccessory.services.find(
    s => s.type === ServiceTypes.THERMOSTAT
  );
  
  if (!service) {
    console.log('No thermostat service found');
    return;
  }
  
  // Type guard with runtime validation
  if (isServiceType<ThermostatService>(service, ServiceTypes.THERMOSTAT)) {
    // TypeScript knows about thermostat-specific characteristics:
    // currenttemperature, targettemperature, currentrelativehumidity, etc.
    
    // Read current temperature (type-safe number)
    const currentTemp: number = service.currenttemperature.value;
    const targetTemp: number = service.targettemperature.value;
    
    console.log(`Current: ${currentTemp}°C, Target: ${targetTemp}°C`);
    
    // Optional humidity if available
    const humidity: number | undefined = service.currentrelativehumidity?.value;
    if (humidity !== undefined) {
      console.log(`Humidity: ${humidity}%`);
    }
    
    // Set new target temperature with type safety
    await HomeAtlas.writeCharacteristic(
      thermostatAccessory.id,
      ServiceTypes.THERMOSTAT,
      CharacteristicTypes.TARGET_TEMPERATURE,
      22.5 // TypeScript ensures this is number
    );
  }
}

// Example 3: Compile-time error prevention
async function demonstrateTypeSafety() {
  const homes = await HomeAtlas.getHomes();
  const service = homes[0].accessories[0].services[0];
  
  // Type guard with runtime validation
  if (isServiceType<LightbulbService>(service, ServiceTypes.LIGHTBULB)) {
    // ✅ This works - TypeScript knows powerstate is Characteristic<boolean>
    const isOn: boolean = service.powerstate.value;
    console.log('Is on:', isOn);
    
    // ✅ This works - optional characteristic properly typed
    const brightness: number | undefined = service.brightness?.value;
    console.log('Brightness:', brightness);
    
    // ❌ This fails at compile-time - TypeScript prevents accessing non-existent properties
    // const invalid = service.nonExistentProperty; // Error: Property 'nonExistentProperty' does not exist
    
    // ❌ This fails at compile-time - TypeScript prevents wrong types
    // const wrongType: string = service.powerstate.value; // Error: Type 'boolean' is not assignable to type 'string'
    
    // ✅ Autocomplete works - IDE shows: powerstate, brightness, hue, saturation, colortemperature
    // service. // <-- Autocomplete shows all available characteristics
  }
}

// Export functions for testing
export {
  controlLightbulb,
  controlThermostat,
  demonstrateTypeSafety
};

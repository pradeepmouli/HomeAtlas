/**
 * Example: Type-Safe Service Access with HomeAtlas
 * 
 * This example demonstrates how User Story 4 enables compile-time type safety
 * and autocomplete for HomeKit services in TypeScript/React Native.
 */

import HomeAtlas, { 
  getTypedService, 
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
  
  // Get type-safe service with full autocomplete
  const typedLight = getTypedService<LightbulbService>(service);
  
  if (typedLight) {
    // TypeScript now knows about lightbulb-specific characteristics
    // and provides autocomplete for: powerstate, brightness, hue, saturation, colortemperature
    
    // Read current state (type-safe boolean)
    const isOn: boolean = typedLight.powerstate.value;
    console.log(`Light is currently: ${isOn ? 'ON' : 'OFF'}`);
    
    // Optional characteristics have proper types
    const brightness: number | undefined = typedLight.brightness?.value;
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
    if (typedLight.brightness) {
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
  
  // Get type-safe service with autocomplete
  const typedThermostat = getTypedService<ThermostatService>(service);
  
  if (typedThermostat) {
    // TypeScript knows about thermostat-specific characteristics:
    // currenttemperature, targettemperature, currentrelativehumidity, etc.
    
    // Read current temperature (type-safe number)
    const currentTemp: number = typedThermostat.currenttemperature.value;
    const targetTemp: number = typedThermostat.targettemperature.value;
    
    console.log(`Current: ${currentTemp}°C, Target: ${targetTemp}°C`);
    
    // Optional humidity if available
    const humidity: number | undefined = typedThermostat.currentrelativehumidity?.value;
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
  const typedLight = getTypedService<LightbulbService>(service);
  
  if (typedLight) {
    // ✅ This works - TypeScript knows powerstate is Characteristic<boolean>
    const isOn: boolean = typedLight.powerstate.value;
    
    // ✅ This works - optional characteristic properly typed
    const brightness: number | undefined = typedLight.brightness?.value;
    
    // ❌ This fails at compile-time - TypeScript prevents accessing non-existent properties
    // const invalid = typedLight.nonExistentProperty; // Error: Property 'nonExistentProperty' does not exist
    
    // ❌ This fails at compile-time - TypeScript prevents wrong types
    // const wrongType: string = typedLight.powerstate.value; // Error: Type 'boolean' is not assignable to type 'string'
    
    // ✅ Autocomplete works - IDE shows: powerstate, brightness, hue, saturation, colortemperature
    // typedLight. // <-- Autocomplete shows all available characteristics
  }
}

// Export functions for testing
export {
  controlLightbulb,
  controlThermostat,
  demonstrateTypeSafety
};

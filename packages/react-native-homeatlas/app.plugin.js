const { withInfoPlist } = require('@expo/config-plugins');

/**
 * Expo config plugin for react-native-homeatlas
 * Adds NSHomeKitUsageDescription to Info.plist
 */
module.exports = function withHomeAtlas(config, props = {}) {
  const homeKitUsageDescription =
    props.homeKitUsageDescription ||
    'This app needs access to HomeKit to control your smart home devices.';

  return withInfoPlist(config, (config) => {
    config.modResults.NSHomeKitUsageDescription = homeKitUsageDescription;
    return config;
  });
};

#!/bin/bash

# ci.sh
# A local version of the ci.yml github action that fires all the jobs sequentially.
# Useful for local validation, keep in sync with .github/workflows/ci.yml
# Note: Execute this script from the root of the repository, such as `./scripts/ci.sh`

# Keep an exit code so that we can return a non-zero exit code if any build fails
# while still running all builds each time.
EXIT_CODE=0
XCODEBUILD_WRAPPER_LOCATION='scripts/xcodebuild_wrapper.sh'

function handle_exit_code()
{
	if [ $? -ne 0 ]
	then
		echo "Previous command exited with non-zero exit code"
		# Intentionally changing the global EXIT_CODE variable
		EXIT_CODE=1
	fi
}


echo "Building and Testing macOS Debug"
$XCODEBUILD_WRAPPER_LOCATION macos_build OfficeUIFabricTestApp Debug build test
handle_exit_code

echo "Building and Testing macOS Release"
$XCODEBUILD_WRAPPER_LOCATION macos_build OfficeUIFabricTestApp Release build test
handle_exit_code

echo "Building and Testing iOS Debug Simulator"
$XCODEBUILD_WRAPPER_LOCATION ios_simulator_build OfficeUIFabric Debug build test
handle_exit_code

echo "Building iOS Release Simulator"
$XCODEBUILD_WRAPPER_LOCATION ios_simulator_build OfficeUIFabric Release build
handle_exit_code

echo "Building iOS Testapp Debug Simulator"
$XCODEBUILD_WRAPPER_LOCATION ios_simulator_build Demo.Development Debug build
handle_exit_code

echo "Building iOS Testapp Release Simulator"
$XCODEBUILD_WRAPPER_LOCATION ios_simulator_build Demo.Development Release build
handle_exit_code

echo "Building iOS Testapp Debug Device"
$XCODEBUILD_WRAPPER_LOCATION ios_device_build Demo.Development Debug build
handle_exit_code

echo "Building iOS Testapp Release Device"
$XCODEBUILD_WRAPPER_LOCATION ios_device_build Demo.Development Release build
handle_exit_code

# Check if any of our individual build steps failed
if [ $EXIT_CODE -ne 0 ]
then
	echo "CI Build Failed, please check logs for failures"
else
	echo "CI Build Succeeded"
fi

exit $EXIT_CODE
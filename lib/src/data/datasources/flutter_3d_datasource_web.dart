// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter_3d_controller/src/core/exception/flutter_3d_controller_exception.dart';
import 'package:flutter_3d_controller/src/data/datasources/i_flutter_3d_datasource.dart';
import 'dart:js' as js;

class Flutter3DDatasource implements IFlutter3DDatasource {
  final String _viewerId;

  Flutter3DDatasource(
    this._viewerId, [
    webViewController,
    activeGestureInterceptor = false,
  ]);

  @override
  void playAnimation({String? animationName}) {
    animationName == null
        ? executeCustomJsCode(
            "const modelViewer = document.getElementById(\"$_viewerId\");"
            "modelViewer.play();",
          )
        : executeCustomJsCode(
            "const modelViewer = document.getElementById(\"$_viewerId\");"
            "modelViewer.animationName = \"$animationName\";"
            "modelViewer.play();",
          );
  }

  @override
  void pauseAnimation() {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.pause();",
    );
  }

  @override
  void resetAnimation() {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.pause();"
      "modelViewer.currentTime = 0;"
      "modelViewer.play();",
    );
  }

  @override
  void stopAnimation() {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.pause();"
      "modelViewer.currentTime = 0;",
    );
  }

  @override
  Future<List<String>> getAvailableAnimations() async {
    try {
      final result = await executeCustomJsCodeWithResult(
        "document.getElementById(\"$_viewerId\").availableAnimations;",
      );
      return result.map<String>((e) => e.toString()).toList();
    } catch (e) {
      throw Flutter3dControllerFormatException(message: 'Failed to retrieve animation list, ${e.toString()}');
    }
  }

  @override
  void setTexture({required String textureName}) {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.variantName = \"$textureName\";",
    );
  }

  @override
  Future<List<String>> getAvailableTextures() async {
    final result = await executeCustomJsCodeWithResult(
      "document.getElementById(\"$_viewerId\").availableVariants;",
    );
    return result.map<String>((e) => e.toString()).toList();
  }

  @override
  void setCameraTarget(double x, double y, double z) {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.cameraTarget = \"${x}m ${y}m ${z}m\";",
    );
  }

  @override
  Future<List<double>> getCameraTarget() async {
    final result = await executeCustomJsCodeWithObjectResult(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.getCameraTarget();",
    );
    return [result['x'], result['y'], result['z']];
  }
  @override
  Future<List<double>> getScreenPosition(double x, double y, double z) async {
    final result = await executeCustomJsCodeWithObjectResult(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.worldToScreen($x, $y, $z);",
    );
    return [result['x'], result['y']];
  }

  @override
  void resetCameraTarget() {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.cameraTarget = \"auto auto auto\";",
    );
  }

  @override
  void setCameraOrbit(double theta, double phi, double radius) {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.cameraOrbit = \"${theta}deg ${phi}deg $radius%\";",
    );
  }

  @override
  Future<List<double>> getCameraOrbit() async {
    final result = await executeCustomJsCodeWithObjectResult(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.getCameraOrbit();",
    );
    return [result["theta"], result["phi"], result["radius"]];
  }

  @override
  Future<double> getFieldOfView() async {
    final result = await executeCustomJsCodeWithDoubleResult(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.getFieldOfView();",
    );
    return result;
  }

  @override
  void resetCameraOrbit() {
    executeCustomJsCode(
      "const modelViewer = document.getElementById(\"$_viewerId\");"
      "modelViewer.cameraOrbit = \"0deg 75deg 105%\" ;",
    );
  }

  @override
  void executeCustomJsCode(String code) {
    js.context.callMethod(
      "customEvaluate",
      [code],
    );
  }

  @override
  Future<dynamic> executeCustomJsCodeWithResult(String code) async {
    final js.JsArray<dynamic> result = await js.context.callMethod("customEvaluateWithResult", [code]);
    return result.toList();
  }

  @override
  Future<dynamic> executeCustomJsCodeWithObjectResult(String code) async {
    final js.JsObject result = await js.context.callMethod("customEvaluateWithResult", [code]);
    return result;
  }

  @override
  Future<double> executeCustomJsCodeWithDoubleResult(String code) async {
    final double result = await js.context.callMethod("customEvaluateWithResult", [code]);
    return result;
  }
}

## 0.1.9

- `CameraView` clips the camera preview to its own box. The preview covers the box (`BoxFit.cover`) and was not
  clipped, while the mask is drawn inside the box only: where the camera's ratio differed from the box's (some
  iPhones), the preview spilled over the widgets above it with no mask on it.

## 0.0.6

- fix the bugs
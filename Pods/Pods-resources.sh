#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *)
      echo "cp -R ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'DLCImagePickerController/Images/FilterSamples/1.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/10.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/10@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/1@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/2.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/2@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/3.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/3@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/4.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/4@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/5.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/5@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/6.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/6@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/7.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/7@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/8.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/8@2x.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/9.jpg'
install_resource 'DLCImagePickerController/Images/FilterSamples/9@2x.jpg'
install_resource 'DLCImagePickerController/Resources/DLCImagePicker.xib'
install_resource 'DLCImagePickerController/Resources/Filters/02.acv'
install_resource 'DLCImagePickerController/Resources/Filters/06.acv'
install_resource 'DLCImagePickerController/Resources/Filters/17.acv'
install_resource 'DLCImagePickerController/Resources/Filters/aqua.acv'
install_resource 'DLCImagePickerController/Resources/Filters/crossprocess.acv'
install_resource 'DLCImagePickerController/Resources/Filters/purple-green.acv'
install_resource 'DLCImagePickerController/Resources/Filters/yellow-red.acv'
install_resource 'DLCImagePickerController/Images/UI/blur-on.png'
install_resource 'DLCImagePickerController/Images/UI/blur-on@2x.png'
install_resource 'DLCImagePickerController/Images/UI/blur.png'
install_resource 'DLCImagePickerController/Images/UI/blur@2x.png'
install_resource 'DLCImagePickerController/Images/UI/camera-button.png'
install_resource 'DLCImagePickerController/Images/UI/camera-button@2x.png'
install_resource 'DLCImagePickerController/Images/UI/camera-icon.png'
install_resource 'DLCImagePickerController/Images/UI/camera-icon@2x.png'
install_resource 'DLCImagePickerController/Images/UI/close.png'
install_resource 'DLCImagePickerController/Images/UI/close@2x.png'
install_resource 'DLCImagePickerController/Images/UI/dock_bg.png'
install_resource 'DLCImagePickerController/Images/UI/dock_bg@2x.png'
install_resource 'DLCImagePickerController/Images/UI/filter-close.png'
install_resource 'DLCImagePickerController/Images/UI/filter-close@2x.png'
install_resource 'DLCImagePickerController/Images/UI/filter-open.png'
install_resource 'DLCImagePickerController/Images/UI/filter-open@2x.png'
install_resource 'DLCImagePickerController/Images/UI/filter.png'
install_resource 'DLCImagePickerController/Images/UI/filter@2x.png'
install_resource 'DLCImagePickerController/Images/UI/flash-auto.png'
install_resource 'DLCImagePickerController/Images/UI/flash-auto@2x.png'
install_resource 'DLCImagePickerController/Images/UI/flash-off.png'
install_resource 'DLCImagePickerController/Images/UI/flash-off@2x.png'
install_resource 'DLCImagePickerController/Images/UI/flash.png'
install_resource 'DLCImagePickerController/Images/UI/flash@2x.png'
install_resource 'DLCImagePickerController/Images/UI/focus-crosshair.png'
install_resource 'DLCImagePickerController/Images/UI/focus-crosshair@2x.png'
install_resource 'DLCImagePickerController/Images/UI/front-camera.png'
install_resource 'DLCImagePickerController/Images/UI/front-camera@2x.png'
install_resource 'DLCImagePickerController/Images/UI/library.png'
install_resource 'DLCImagePickerController/Images/UI/library@2x.png'
install_resource 'DLCImagePickerController/Images/UI/micro_carbon.png'
install_resource 'DLCImagePickerController/Images/UI/micro_carbon@2x.png'
install_resource 'DLCImagePickerController/Images/UI/photo_bar.png'
install_resource 'DLCImagePickerController/Images/UI/photo_bar@2x.png'
install_resource 'DLCImagePickerController/Images/Overlays/blackframe.png'
install_resource 'DLCImagePickerController/Images/Overlays/mask.png'

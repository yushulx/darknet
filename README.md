# QR Code Detection with Yolo v3 Model for Windows

The repository aims to do **QR Code detection** with Yolo v3 model and decode **QR Code** in region using [Dynamsoft Barcode Reader](https://www.dynamsoft.com/Products/Dynamic-Barcode-Reader.aspx). 

## Download Pre-trained Yolo3 Model for QR Code
- [yolov3-tiny.weights for QR Code](https://www.dynamsoft.com/handle-download?productId=1000003&downloadLink=https://download.dynamsoft.com/codepool/ml/yolo3-tiny-qr.zip)
- [yolov3.weights for QR Code](https://www.dynamsoft.com/handle-download?productId=1000003&downloadLink=https://download.dynamsoft.com/codepool/ml/yolo3-qr.zip)

## License for Dynamsoft Barcode Reader
To get barcode decoding results, you need to get a valid trial license from https://www.dynamsoft.com/customer/license/trialLicense. Then update the following code in `detector.c`:

```c
DBR_InitLicense(barcodeReader, "LICENSE-KEY");
```

## How to Build and Run Darknet on Windows

Install:

- CMake 3.18.4
- Visual Studio 2019 Community edition
- OpenCV 4.5.0. Add `OpenCV_DIR = C:\opencv\build` to system environment variables.
- CUDA 10.1. Copy `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\extras\visual_studio_integration\MSBuildExtensions` to `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v160\BuildCustomizations`
- cuDNN 7.6.5

Run `build.ps1` in PowerShell to build `darknet.exe`.

Copy `darknet\3rdparty\dbr\bin\DynamsoftBarcodeReaderx64.dll` and `darknet\3rdparty\dbr\bin\vcomp110.dll` to `darknet\`

Extract the model package to the test folder and then run the test:

```
cd test
..\darknet.exe detector test qrcode.data qrcode-yolov3-tiny.cfg qrcode-yolov3-tiny_last.weights 20201105151910.jpg
```

Yolov3
![Yolov3](test/yolov3.jpg)

Yolov3-tiny
![Yolov3-tiny](test/yolov3-tiny.jpg)

## How to Get the QR Code Region

```c
int selected_detections_num;
detection_with_class* selected_detections = get_actual_detections(dets, nboxes, thresh, &selected_detections_num, names);
qsort(selected_detections, selected_detections_num, sizeof(*selected_detections), compare);
int i;
for (i = 0; i < selected_detections_num; ++i) {
    const int best_class = selected_detections[i].best_class;
    printf("%s: %.0f%%\n\n", names[best_class],    selected_detections[i].det.prob[best_class] * 100);
    box b = selected_detections[i].det.bbox;
    int left = (b.x - b.w / 2.)*im.w;
    int right = (b.x + b.w / 2.)*im.w;
    int top = (b.y - b.h / 2.)*im.h;
    int bot = (b.y + b.h / 2.)*im.h;

    #ifdef OPENCV
        decode_barcode_buffer(image_buffer, im.w, im.h, im.c, TRUE, left, right, top, bot);
    #endif  
}

```

## How to Decode QR Code within the Region

```c
void decode_barcode_buffer(const unsigned char *data, int width, int height, int channel, boolean has_region, int left, int right, int top, int bottom) 
{
    void* barcodeReader = DBR_CreateInstance();
    // Apply for a valid license https://www.dynamsoft.com/customer/license/trialLicense
    DBR_InitLicense(barcodeReader, "t0260NwAAAHV***************");

    if (has_region)
    {
        PublicRuntimeSettings settings;
        char errorMessage[256];
        int errorCode = DBR_GetRuntimeSettings(barcodeReader, &settings);
        settings.region.regionLeft = left;
        settings.region.regionRight = right;
        settings.region.regionTop = top;
        settings.region.regionBottom = bottom;
        settings.region.regionMeasuredByPercentage = 0;
        settings.barcodeFormatIds = BF_QR_CODE;
        DBR_UpdateRuntimeSettings(barcodeReader, &settings, errorMessage, 256);
    }

    double time = get_time_point();
    ImagePixelFormat format = IPF_RGB_888;
    if (channel == 1)
    {
        format = IPF_GRAYSCALED;
    }
    else if (channel == 4)
    {
        format = IPF_ARGB_8888;
    }

    int errorCode = DBR_DecodeBuffer(barcodeReader, data, width, height, width * channel, format, "");

    printf(" Barcode buffer decoding in %lf milli-seconds.\n", ((double)get_time_point() - time) / 1000);

    TextResultArray *resultArray = NULL;
    DBR_GetAllTextResults(barcodeReader, &resultArray);
    if (resultArray->resultsCount == 0)
    {
        printf("No barcode found.\n");
    }
    else
    {
        int index = 0;
        for (; index < resultArray->resultsCount; index++)
        {
            printf(" Type: %s, Value: %s \n\n", resultArray->results[index]->barcodeFormatString, resultArray->results[index]->barcodeText);
        }	
    }
    
    DBR_FreeTextResults(&resultArray);
    DBR_DestroyInstance(barcodeReader);
}
```

## About Darknet
https://github.com/AlexeyAB/darknet
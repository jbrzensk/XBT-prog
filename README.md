# XBT-prog
New updated XBT processing files (2025) for XBT analysis.

See detailed first use instructions in [Startup Instructions](Startup_Instructions.md).

## To run and process a data set

### Move Edited files and create symbolic links in raw

Navigate to the "raw" directory and run
```
run_analysis.sh
```

This moves files, creates some symbolic links, and moves the edited files up to the directory above.

### Create images for FERRET
Navigate to the directory above, and run the image generation script
```
cd ..
run_image_gen.sh
```

### Create web images and move to ARGO
In the same directory, run the final script for the line, which creates the three scaled images, and moves them to the argo directory.

```
line_2025.sh
```

## Lines
This code has been tested on the following lines


- [ ] PX05
- [x] PX06
- [x] PX09
- [x] PX13
- [ ] PX30??
- [ ] PX31 - data?
- [ ] PX34
- [ ] PX37
- [x] PX37s
- [ ] PX38
- [x] PX40

### Not Supported
- [x] PX15
- [ ] PX39
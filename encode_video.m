clc;
clear all;
warning('off', 'Images:initSize:adjustingMag');

soundvideo_black = 'vassar_sound_black.yuv';
soundvideo = 'vassar_sound.yuv';
input = 'vassar.yuv';

%create black video
frames=32;
fileID = fopen(soundvideo_black,'w');
fw=640;
fh=480;
tempY=zeros(1,fw*fh);
tempUV=128*ones(1,fw*fh/2);
for f=1:frames
     fwrite(fileID,tempY,'uint8');
     fwrite(fileID,tempUV,'uint8');
end
fclose(fileID);

%create sound video
%comment it and just use your sound video file name soundvideo
if 1
    fileID = fopen(input,'r');
    tempY = fread(fileID,fw*fh,'uint8');
    tempUV = fread(fileID,fw*fh/2,'uint8');
    fclose(fileID);
    
    fileID = fopen(soundvideo,'w');
    for f=1:frames
         fwrite(fileID,tempY,'uint8');
         fwrite(fileID,tempUV,'uint8');
    end
    fclose(fileID);
end

%encoding without 
% qp = [15,20,30,40]; РК
qp = [15]; %ЗК


if 1
    copyfile(soundvideo_black,'soundvideo.yuv');
    copyfile(input,'input.yuv');
    for i=1:length(qp)
        %Encode via 3D-HEVC
        s = sprintf('"./mvhm/3dhevc/TAppEncoderStatic" -c "./mvhm/3dhevc/baseCfg_2view.cfg" -c "./mvhm/3dhevc/seqCfg.cfg" -b "./mvhm/3dhevc/video.bin" -q %i -f %i',qp(i),frames);
        system(s);
        %Decode via 3D-HEVC 
        s = sprintf('"./mvhm/3dhevc/TAppDecoderStatic" -b "./mvhm/3dhevc/video.bin" -o "./input_dec.yuv"');
        system(s);

        s = sprintf('input_dec_noSound%i.yuv',i);
        copyfile('input_dec_1.yuv',s);
        
        PSNR = PSNRfromFile(input, s, fw,fh,frames);
        fileID = fopen('results.txt','at');
        fprintf(fileID,'NoSound: Q=%i PSNR=%g\n',qp(i),PSNR);
        fclose(fileID);

    end
end

copyfile(soundvideo,'soundvideo.yuv');
copyfile(input,'input.yuv');
for i=1:length(qp)
    %Encode via 3D-HEVC
    s = sprintf('"./mvhm/3dhevc/TAppEncoderStatic" -c "./mvhm/3dhevc/baseCfg_2view.cfg" -c "./mvhm/3dhevc/seqCfg.cfg" -b "./mvhm/3dhevc/video.bin" -q %i -f %i',qp(i),frames);
    system(s);
    %Decode via 3D-HEVC 
    s = sprintf('"./mvhm/3dhevc/TAppDecoder.exe" -b "./mvhm/3dhevc/video.bin" -o "./input_dec.yuv"');
    system(s);
    s = sprintf('input_dec_Sound%i.yuv',i);
    copyfile('input_dec_1.yuv',s);
    
    PSNR = PSNRfromFile(input, s, fw,fh,frames);
    fileID = fopen('results.txt','at');
    fprintf(fileID,'WithSound: Q=%i PSNR=%g\n',qp(i),PSNR);
    fclose(fileID);
end





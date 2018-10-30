%read image
imdata = imread('wm.bmp');
imBin=reshape(imdata',1,64^2);

%read audio
imBin=double(imBin);
[y, Fs]=audioread('mike.wav');

%apply fast fourier
f=fft(y); 

%store phase angles
P=angle(f);

%get amplitudes
amp=abs(f);
embed=amp;

%find index of max amplitude add pixel to that aplitude, construct complex
%numbers with new amplitude and known phase angles, make max amplitude zero
%and search again for max amplitude

for k=1:2716
    c=find(amp==max(amp));
    p=[(tan(P(c(1))))^2+1 0 -1*(amp(c(1))+imBin(k))^2];
    pp=[(tan(P(c(1))))^2+1 0 -1*(amp(c(1))+imBin(k))^2*(tan(P(c(1))))^2];
    r=roots(p);
    rr=roots(pp);
    f(c(1))=r(1)+rr(1)*1i;
    amp(c(1))=0;
end

%apply inverse fft and listen to sound
yy=ifft(f);
yy=real(yy);
sound(yy, Fs);


 %calculate SNR value of original sound and watermarked sound
  t1=0;
  t2=0;
    for p=1:length(y)
        t1=t1+y(p)*y(p);
        t2=t2+(yy(p)-y(p))*(yy(p)-y(p));
    end
    
 SNR=10*log10(t1/t2);

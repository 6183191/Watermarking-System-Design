%read image data
imdata = imread('wm.bmp');
dataRow=reshape(imdata',1,64^2);

%make image data a row vector with bits
dataBin=dec2bin(dataRow,8);
imBin = str2num(reshape(dataBin',[],1))';

%hopping sequence
hop=[2 3 3 4 5];

%read audio and convert to mu values
[y, Fs]=audioread('mike.wav');
mu=lin2mu(y);
audioBytes=mu;

%convert audio to bytes
for i=1:length(mu)
audioBytes(i)=str2num(dec2bin(mu(i),8));
end

%embed image data 1 in 4 bytes
n=0;
for k=0:length(imBin)-1
    n=hop(mod(k,5)+1);

  if imBin(k+1)==1  

   mm=dec2bin(bitor(bin2dec(num2str(audioBytes(4*k+1))),2^(n-1)),8);
  audioBytes(4*k+1)=str2num(mm);
  
  else
      
    mm=dec2bin(bitand(bin2dec(num2str(audioBytes(4*k+1))),255-2^(n-1)),8);
    audioBytes(4*k+1)=str2num(mm);  
    
  end    
end
  imBinn=imBin;

%extract image data
for k=0:length(imBin)-1
    n=hop(mod(k,5)+1);
    endBit=bitand(bin2dec(num2str(audioBytes(4*k+1))),2^(n-1))/2^(n-1);
    imBin(k+1)=endBit;
end

for i=1:length(audioBytes)
    audioBytes(i)=bin2dec(num2str(audioBytes(i)));
end

%convert mu values back to lin and listen to watermarked audio
lin=mu2lin(audioBytes);
sound(lin', Fs);

[imBin] = vec2mat(imBin,8);

%save image
 imBin=bin2dec(num2str(imBin));
 [imBin]= vec2mat(imBin',64);
 K=mat2gray(imBin);
 imwrite(K,'lenaTime.bmp');
 
  %calculate SNR value of original sound and watermarked sound
  t1=0;
  t2=0;
    for p=1:length(y)
        t1=t1+y(p)*y(p);
        t2=t2+(lin(p)-y(p))*(lin(p)-y(p));
    end
    
 SNR=10*log10(t1/t2);

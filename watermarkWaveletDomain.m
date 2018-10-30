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

%calculate low,high pass values
k=1;
while 2*k+1<=length(y)
    
    H1(k)=(y(2*k)-y(2*k+1))/2;
    L1(k)=(y(2*k)+y(2*k+1))/2;
    k=k+1;
end
k=1;
 
while 2*k+1<=length(L1)
    
    H2(k)=(L1(2*k)-L1(2*k+1))/2;
    L2(k)=(L1(2*k)+L1(2*k+1))/2;
    k=k+1;
end   

%concatenate and convert to mu values
mu=lin2mu([L2;H2;H1]);
audioBytes = mu;

%convert audio to byte
for i=1:length(audioBytes)
audioBytes(i)=str2num(dec2bin(mu(i),8));
end

%embed image data 1 in for bytes
for j=0:length(imBin)-1
    n=hop(mod(j,5)+1);

  if imBin(j+1)==1  

   mm=dec2bin(bitor(bin2dec(num2str(audioBytes(4*j+1))),2^(n-1)),8);
  audioBytes(4*j+1)=str2num(mm);
  
  else
      
    mm=dec2bin(bitand(bin2dec(num2str(audioBytes(4*j+1))),255-2^(n-1)),8);
    audioBytes(4*j+1)=str2num(mm);  
    
  end    
end

%convert audio bytes to decimal and then lin values for inverse dwt
for i=1:length(audioBytes)
    audioBytes(i)=bin2dec(num2str(audioBytes(i)));
end

 lin=mu2lin(audioBytes);

%calculate concatenated low,high pass values 
LL2=lin(1:length(L2)); 
HH2=lin(length(L2)+1:length(L2)+length(H2));
HH1=lin(length(L2)+length(H2)+1:length(L2)+length(H2)+length(H1));

%Apply 2-level inverse DWT
LL1=zeros(1,length(L1));

k=1;
while k*2+1<=length(LL1)
   LL1(k*2)=LL2(k)+HH2(k);
   LL1(k*2+1)=LL2(k)-HH2(k);
   k=k+1;
end

S=zeros(1,length(y));

k=1;
while k*2+1<=length(S)
   S(k*2)=LL1(k)+HH1(k);
   S(k*2+1)=LL1(k)-HH1(k);
   k=k+1;
end

sound(S, Fs);

%Apply 2-level DWT to watermarked audio

k=1;
while 2*k+1<=length(S)
    
    H1(k)=(S(2*k)-S(2*k+1))/2;
    L1(k)=(S(2*k)+S(2*k+1))/2;
    k=k+1;
end
k=1;
 
while 2*k+1<=length(L1)
    
    H2(k)=(L1(2*k)-L1(2*k+1))/2;
    L2(k)=(L1(2*k)+L1(2*k+1))/2;
    k=k+1;
end   

%convert to mu values
mu=lin2mu([L2;H2;H1]);
audioBytes = mu;

%convert audio to byte
for i=1:length(audioBytes)
audioBytes(i)=str2num(dec2bin(mu(i),8));
end

%extract image data
for k=0:length(imBin)-1
    n=hop(mod(k,5)+1);
    endBit=bitand(bin2dec(num2str(audioBytes(4*k+1))),2^(n-1))/2^(n-1);
    imBin(k+1)=endBit;
end

[imBin] = vec2mat(imBin,8);

%save image

imBin=bin2dec(num2str(imBin));
[imBin]= vec2mat(imBin',64);
 K=mat2gray(imBin);
 imwrite(K,'lenaDWT.bmp');

 
 %calculate SNR value of original sound and watermarked sound
  t1=0;
  t2=0;
    for p=1:length(y)
        t1=t1+y(p)*y(p);
        t2=t2+(S(p)-y(p))*(S(p)-y(p));
    end
    
 SNR=10*log10(t1/t2);
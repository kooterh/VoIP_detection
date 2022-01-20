function [voiceseg,vsl,SF,NF,flag]=vad_param1D(dst1,T1,T2)
fn=size(dst1,2);                       % ȡ��֡��
maxsilence = 8;                        % ��ʼ��  
minlen  = 5;    
status  = 0;
count   = 0;
silence = 0;
xn=1;
warning('off')
for n=2:fn
   switch status
   case {0,1}% 0 = ����, 1 = ���ܿ�ʼ
      %disp('0,1')
      if dst1(n) > T2                   % ȷ�Ž���������
         %disp('0')
         x1(xn) = max(n-count(xn)-1,1);
         status  = 2;
         silence(xn) = 0;
         count(xn)   = count(xn) + 1;
      elseif dst1(n) > T1               % ���ܴ���������
         %dispp('1')
%             zcr(n) < zcr2
         status = 1;
         count(xn)  = count(xn) + 1;
      else                              % ����״̬
         %disp('2')
         status  = 0;
         count(xn)= 0;
         x1(xn)=0;
         x2(xn)=0;
      end
   case 2, % 2 = ������
      %disp('2')
      if dst1(n) > T1                   % ������������
         count(xn) = count(xn) + 1;
      else                              % ����������
         silence(xn) = silence(xn)+1;
         if silence(xn) < maxsilence    % ����������������δ����
            count(xn)  = count(xn) + 1;
         elseif count(xn) < minlen      % ��������̫�̣���Ϊ������
            status  = 0;
            silence(xn) = 0;
            count(xn)   = 0;
         else                           % ��������
            status  = 3;
            x2(xn)=x1(xn)+count(xn);
         end
      end
   case 3,                              % ����������Ϊ��һ������׼��
        %disp('3')
        status  = 0;          
        xn=xn+1; 
        count(xn)   = 0;
        silence(xn)=0;
        x1(xn)=0;
        x2(xn)=0;
   end
end
el=length(x1);
%disp('fuck111111')
if el>1
    flag=0;
    if x1(el)==0, el=el-1; end              % ���x1��ʵ�ʳ���
    if el==0, return; end
    if x2(el)==0                            % ���x2���һ��ֵΪ0����������Ϊfn
        fprintf('Error: Not find endding point!\n');
        x2(el)=fn;
    end
    SF=zeros(1,fn);                         % ��x1��x2����SF��NF��ֵ
    NF=ones(1,fn);
    for i=1 : el
        SF(x1(i):x2(i))=1;
        NF(x1(i):x2(i))=0;
    end
    speechIndex=find(SF==1);                % ����voiceseg
    voiceseg=findSegment(speechIndex);
    vsl=length(voiceseg);
else
    flag=1;
    vsl=0;
    voiceseg=0;
    SF=0;
    NF=0;
    
    
end
function read_voip_for_resampling_20100112(filepath1,filepath2,mismatch_path1,mismatch_path2,train_rate,val_rate,datanum,mismatch_num,save_path,p,frame_length)
file_number1=size((dir(filepath1)),1)   
file_number2=size((dir(filepath2)),1)  
k1=randperm(file_number1-2);
k2=randperm(file_number2-2);
disp('kkkkkkkk')
mismatch_r=randperm(mismatch_num);
train_number=datanum*train_rate;
val_number=datanum*val_rate;

if mismatch_num==0
    test_number=datanum-train_number-val_number;
else
    test_number=0;
end
%save([save_path,'/random_read.mat'],'-v7.3','k1','k2','mismatch_r')
%load('/home/huangyuankun/VOIP/data/2s/20171222_all_data/20180626_final/different_software/alicall_ailiao/without_resampling/mat/random_read.mat')

parfor i=1:datanum
    disp(['datanum1 index :',num2str(i)])
    k1(i)
    filename1=[filepath1,'/',num2str(k1(i)),'.wav'];
    warning off
    [samples,fs]=audioread(filename1);
    samples=samples(end-fs*2+1:end);
    wav1=highpass_filter2(samples,1,1);
    [~,log_mel,ilog_mel,~]=get_log_melspec(wav1,floor(fs*frame_length),floor(fs*frame_length),0.5,p,fs);
    log_mel=twoD_norm(log_mel);ilog_mel=twoD_norm(ilog_mel);
    train_log_mel_x1(:,:,i)=log_mel;
    train_ilog_mel_x1(:,:,i)=ilog_mel;
    train_all_wav1(i,:)=wav1;
    train_wav1(:,:,i)=enframe(wav1,hamming(fs*frame_length),floor(fs*frame_length*0.5));
    
    disp(['datanum1 index :',num2str(i)])
    k2(i)
    filename2=[filepath2,'/',num2str(k2(i)),'.wav'];
    warning off
    [samples2,fs2]=audioread(filename2);
    samples2=samples2(end-fs2*2+1:end);
    wav2=highpass_filter2(samples2,1,1);
    [~,log_mel2,ilog_mel2,~]=get_log_melspec(wav2,floor(fs2*frame_length),floor(fs2*frame_length),0.5,p,fs2);
    log_mel2=twoD_norm(log_mel2);ilog_mel2=twoD_norm(ilog_mel2);
    train_log_mel_x2(:,:,i)=log_mel2;
    train_ilog_mel_x2(:,:,i)=ilog_mel2;
    train_all_wav2(i,:)=wav2;
    train_wav2(:,:,i)=enframe(wav2,hamming(fs2*frame_length),floor(fs2*frame_length*0.5));
end

parfor i=1:mismatch_num
    disp(['mismatch index :',num2str(i)])
    mismatch_name1=[mismatch_path1,'/',num2str(mismatch_r(i)),'.wav'];
    warning off
    [samples,fs]=audioread(mismatch_name1);
    samples=samples(end-fs*2+1:end);
    wav1=highpass_filter2(samples,1,1)
    [~,log_mel,ilog_mel,~]=get_log_melspec(wav1,floor(fs*frame_length),floor(fs*frame_length),0.5,p,fs);
    log_mel=twoD_norm(log_mel);ilog_mel=twoD_norm(ilog_mel);
    mismatch_log_mel_x1(:,:,i)=log_mel;
    mismatch_ilog_mel_x1(:,:,i)=ilog_mel;
    mismatch_all_wav1(i,:)=wav1;
    mismatch_wav1(:,:,i)=enframe(wav1,hamming(fs*frame_length),floor(fs*frame_length*0.5));

    mismatch_name2=[mismatch_path2,'/',num2str(mismatch_r(i)),'.wav'];
    warning off
    [samples2,fs2]=audioread(mismatch_name2);
    samples2=samples2(end-fs2*2+1:end);
    wav2=highpass_filter2(samples2,1,1);
    [~,log_mel2,ilog_mel2,~]=get_log_melspec(wav2,floor(fs2*frame_length),floor(fs2*frame_length),0.5,p,fs2);
    log_mel2=twoD_norm(log_mel2);ilog_mel2=twoD_norm(ilog_mel2);
    mismatch_log_mel_x2(:,:,i)=log_mel2;
    mismatch_ilog_mel_x2(:,:,i)=ilog_mel2;
    mismatch_all_wav2(i,:)=wav2;
    mismatch_wav2(:,:,i)=enframe(wav2,hamming(fs2*frame_length),floor(fs2*frame_length*0.5));
end

disp('train_finished!!')

disp('saving1:')
train_x=cat(3,train_log_mel_x1(:,:,1:train_number),train_log_mel_x2(:,:,1:train_number));
train_y=[repmat([1,0],train_number,1);repmat([0,1],train_number,1)];
trainnum=size(train_x,3);train_random=randperm(trainnum);
train_x=train_x(:,:,train_random);train_y=train_y(train_random,:);
val_x=cat(3,train_log_mel_x1(:,:,train_number+1:train_number+val_number),train_log_mel_x2(:,:,train_number+1:train_number+val_number));
val_y=[repmat([1,0],val_number,1);repmat([0,1],val_number,1)];
valnum=size(val_x,3);val_random=randperm(valnum);
val_x=val_x(:,:,val_random);val_y=val_y(val_random,:);
if mismatch_num==0
    mismatch_x=cat(3,train_log_mel_x1(:,:,train_number+val_number+1:end),train_log_mel_x2(:,:,train_number++val_number+1:end));
    mismatch_y=[repmat([1,0],test_number,1);repmat([0,1],test_number,1)];
    save([save_path,'/train_norm_per_sample_logmel.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
else
    mismatch_x=cat(3,mismatch_log_mel_x1,mismatch_log_mel_x2);
    mismatch_y=[repmat([1,0],size(mismatch_log_mel_x1,3),1);repmat([0,1],size(mismatch_log_mel_x2,3),1)];
    save([save_path,'/train_norm_per_sample_logmel.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
end
clear train_x val_x mismatch_x

disp('saving4:')
train_x=[train_all_wav1(1:train_number,:);train_all_wav2(1:train_number,:)];train_x=train_x(train_random,:);
val_x=[train_all_wav1(1+train_number:train_number+val_number,:);train_all_wav2(1+train_number:train_number+val_number,:)];val_x=val_x(val_random,:);
if mismatch_num==0
    mismatch_x=[train_all_wav1(train_number+val_number+1:end,:);train_all_wav2(train_number+val_number+1:end,:)];
    save([save_path,'/train_norm_per_sample_allwav.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
else
    mismatch_x=[mismatch_all_wav1;mismatch_all_wav2];
    save([save_path,'/train_norm_per_sample_allwav.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
end
clear train_x val_x mismatch_x

disp('saving2:')
train_x=cat(3,train_ilog_mel_x1(:,:,1:train_number),train_ilog_mel_x2(:,:,1:train_number));train_x=train_x(:,:,train_random);
val_x=cat(3,train_ilog_mel_x1(:,:,train_number+1:train_number+val_number),train_ilog_mel_x2(:,:,train_number+1:train_number+val_number));
val_x=val_x(:,:,val_random);
if mismatch_num==0
    mismatch_x=cat(3,train_ilog_mel_x1(:,:,train_number+val_number+1:end),train_ilog_mel_x2(:,:,train_number++val_number+1:end));
    save([save_path,'/train_norm_per_sample_ilogmel.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
else
    mismatch_x=cat(3,mismatch_ilog_mel_x1,mismatch_ilog_mel_x2);
    save([save_path,'/train_norm_per_sample_ilogmel.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
end
clear train_x val_x mismatch_x
disp('saving3:')
train_x=cat(3,train_wav1(:,:,1:train_number),train_wav2(:,:,1:train_number));train_x=train_x(:,:,train_random);
val_x=cat(3,train_wav1(:,:,train_number+1:train_number+val_number),train_wav2(:,:,train_number+1:train_number+val_number));val_x=val_x(:,:,val_random);
if mismatch_num==0
    mismatch_x=cat(3,train_wav1(:,:,train_number+val_number+1:end),train_wav2(:,:,train_number++val_number+1:end));
    save([save_path,'/train_norm_per_sample_framewav.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
else
    mismatch_x=cat(3,mismatch_wav1,mismatch_wav2);
    save([save_path,'/train_norm_per_sample_framewav.mat'],'-v7.3','train_x','train_y','val_x','val_y','mismatch_x','mismatch_y')
end
clear train_x val_x mismatch_x

disp('finish!!')
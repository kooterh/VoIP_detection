function spilt_voip_vad_data(inpath,savepath)
temp=dir(inpath);
file_length=length(temp);
for i=3:file_length
    temp_name=temp(i).name;
    readname=[inpath,'/',temp_name];
    vad_myself_read_wav(readname,savepath)
end
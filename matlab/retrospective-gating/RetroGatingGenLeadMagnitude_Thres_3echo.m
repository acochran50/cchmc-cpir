
%% Created by Jinbang Guo
%%This method finds the local  mean maxima and minima of the magnitude of the leading fid point as a function
%%of the fid number. The expiration or inspiration data corresponding to the magnitude around the maxima (>maxima-15%*(maxima-minima)) or
%%minima (<minima+15%*(maxima-minima)). The output traj_ and fid_
%%inspiration/expiration files are input of sdc.m and grid.m.
% for i = 30:30
% pathName = '/home/jinbang/ReconMethod/20160311raw/53';
pathName=char(pwd);
NPro = 29556;
NCutPro=0; % cut leading projections.
NPoints = 101;
RealNPro = NPro - NCutPro;
numsep=180;
separation=round(RealNPro/numsep);
% separation=83700/numsep;
threshold_percent_exp=0.27;
threshold_percent_insp=0.15;
fid = fopen(fullfile(pathName,'fid'));

kdata = fread(fid,[2,inf],'int32');
fclose(fid);

kdata_cmplx=complex(kdata(1,:),kdata(2,:));
magnitude = abs(kdata_cmplx);

magnitude = reshape(magnitude,[128 NPro*3]);
magnitudeAll3Echos=magnitude;
kdataAll3Echos=kdata;
clear kdata;

fileNameStr={'0800','2000','4000'}; % ECHO_FID_ARR

for echoIndex=1:3

    magnitude=magnitudeAll3Echos(:,echoIndex:3:NPro*3-3+echoIndex);
    for index=1:NPro
        kdata(:,(index-1)*128+1:index*128)=...
            kdataAll3Echos(:,(echoIndex-1)*128+1+(index-1)*128*3: ... 
            echoIndex*128+(index-1)*128*3);
%         disp((index-1)*128+1:index*128);
%         disp((echoIndex-1)*128+1+(index-1)*128*3: ... 
%             echoIndex*128+(index-1)*128*3);
    end
        
magnitude_leading=squeeze(magnitude(20,NCutPro+1:NPro));

SelectVector_exp=zeros(1,RealNPro);
SelectVector_insp=zeros(1,RealNPro);

subplot(3,1,echoIndex);
plot(magnitude_leading,'o','MarkerEdgeColor','b','MarkerFaceColor','w','MarkerSize',5);

for i=1:numsep
    minpeakheight=(max(magnitude_leading((i-1)*separation+1:i*separation))+min(magnitude_leading((i-1)*separation+1:i*separation)))/2;
    [peaks,indx_exp]=findpeaks(magnitude_leading((i-1)*separation+1:i*separation),'MINPEAKHEIGHT',minpeakheight);
%     mean_max=mean(peaks);
    mean_max=max(peaks);
    [peaks,indx_insp]=findpeaks(-magnitude_leading((i-1)*separation+1:i*separation),'MINPEAKHEIGHT',-minpeakheight);
%     mean_min=-mean(peaks);
    mean_min=-max(peaks);
    threshold=mean_max-threshold_percent_exp*(mean_max-mean_min);
    SelectVector_exp(1,(i-1)*separation+1:i*separation)=magnitude_leading((i-1)*separation+1:i*separation)>threshold;
    threshold=mean_min+threshold_percent_insp*(mean_max-mean_min);
    SelectVector_insp(1,(i-1)*separation+1:i*separation)=magnitude_leading((i-1)*separation+1:i*separation)<threshold;
end

SelectVector_exp=logical(SelectVector_exp);
SelectVector_insp=logical(SelectVector_insp);

plot(magnitude_leading,'o','MarkerEdgeColor','b','MarkerFaceColor','w','MarkerSize',5);hold on;
xlabel(strcat(['fid# [TE: ',char(fileNameStr(echoIndex)),' us)']),'FontSize',10,'FontWeight','bold','Color','k');
ylabel('phase (radians)','FontSize',10,'FontWeight','bold','Color','k');
title('Leading phase of each spoke','FontSize',15,'FontWeight','bold','Color','k');

magnitude_exp=magnitude_leading(SelectVector_exp);
locs_exp=find(SelectVector_exp);
plot(locs_exp,magnitude_exp,'ro');

magnitude_insp=magnitude_leading(SelectVector_insp);
locs_insp=find(SelectVector_insp);
plot(locs_insp,magnitude_insp,'gs');
hold off;
xlim([1 1000]);

kdata = reshape(kdata,[2 128 NPro]);
kdata = kdata(:,:,NCutPro+1:NPro);
kdata_exp = kdata(:,:,SelectVector_exp);
'expiration Number of Projections:'
ExpNPro = size(kdata_exp,3)
fid = fopen(fullfile(pathName,strcat(['fid_expiration',char(fileNameStr(echoIndex))])),'w');
fwrite(fid,kdata_exp,'int32');
fclose(fid);

fid = fopen(fullfile(pathName,'traj'));
trajectory = reshape(fread(fid,[3,inf],'double'),[3 NPoints NPro*3]);
fclose(fid);
trajectoryAll3Echoes=trajectory;clear trajectory;
trajectory = trajectoryAll3Echoes(:,:,NCutPro+echoIndex:3:NPro*3-3+echoIndex);
trajectory_exp = trajectory(:,:,SelectVector_exp);
fid = fopen(fullfile(pathName,strcat(['traj_expiration_',char(fileNameStr(echoIndex))])),'w');
fwrite(fid,trajectory_exp,'double');
fclose(fid);


kdata_insp = kdata(:,:,SelectVector_insp);
% 'inspiration Number of Projections:'
InspNPro = size(kdata_insp,3);
fid = fopen(fullfile(pathName,'fid_inspiration'),'w');
fwrite(fid,kdata_insp,'int32');
fclose(fid);

trajectory_insp = trajectory(:,:,SelectVector_insp);
fid = fopen(fullfile(pathName,'traj_inspiration'),'w');
fwrite(fid,trajectory_insp,'double');
fclose(fid);

end

set(gcf,'Position',[50 80 1420 680]);
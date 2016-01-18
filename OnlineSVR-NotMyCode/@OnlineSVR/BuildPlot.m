%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Build a plot with the current OnlineSVR

function [SVR] = BuildPlot (SVR, ShowAxis)        
    
    % Parameters
    nx = 100;
    ngrid = 2*nx+1;
    bandwidth = 50;
    borderwidth = 50;
        
    % Compute the grid
    clear figures;
    if (SVR.SamplesTrainedNumber>0)
        xmin = min(min(SVR.X),[],1);
        xmax = max(max(SVR.X),[],1);        
        if (xmin==xmax)
            xmin = xmin-1;
            xmax = xmax+1;
        end
        xmin = floor(xmin);
        xmax = ceil(xmax);
        xstep = (xmax-xmin)/(ngrid-1);
        xmax = xmax+borderwidth*xstep;
        xmin = xmin-borderwidth*xstep;
    else
        xmin = -1;
        xmax = 1;
        xstep = (xmax-xmin)/(ngrid-1);
    end

    xgrid = (xmin:xstep:xmax)';
    ygrid = Predict(SVR, xgrid);
    
    if (SVR.SamplesTrainedNumber>0)
        ymin = min([ygrid; SVR.Y],[],1);
        ymax = max([ygrid; SVR.Y],[],1);
        if (ymax-ymin<1)
            ymin = ymin-1;
            ymax = ymax+1;
        end
        ymin = floor(ymin);
        ymax = ceil(ymax);
        ystep = (ymax-ymin)/(ngrid-1);
        ymin = ymin-borderwidth*ystep;
        ymax = ymax+borderwidth*ystep;
    else
        ymin = min(ygrid,[],1);
        ymax = max(ygrid,[],1);
        if (ymax-ymin<1)
            ymin = ymin-1;
            ymax = ymax+1;
        end
        ymin = floor(ymin);
        ymax = ceil(ymax);
        ystep = (ymax-ymin)/(ngrid-1);
        ymax = ymax+borderwidth*ystep;
        ymin = ymin-borderwidth*ystep;
    end 
    
    lowbandwidth = floor(SVR.Epsilon/ystep)+1;
    if (lowbandwidth>bandwidth)
        lowbandwidth=bandwidth;
    end    
    
    % Palette
    blackwhite = (0:1/(bandwidth-1):1)';
    
    whiteblue=zeros(bandwidth,3);
    whiteblue(:,1) = 1-blackwhite;
    whiteblue(:,2) = 1-blackwhite;
    whiteblue(:,3) = 1;
    
    whiteyellow=zeros(bandwidth,3);
    whiteyellow(:,1) = 1;
    whiteyellow(:,2) = 1;
    whiteyellow(:,3) = 1-blackwhite;

    whiteyellowblue(1:lowbandwidth,:) = whiteyellow(1:lowbandwidth,:);
    whiteyellowblue((lowbandwidth+1):bandwidth,:) = whiteblue((lowbandwidth+1):bandwidth,:);

    blueyellowwhite = whiteyellowblue(bandwidth-1:-1:1,:);
    
    color= [blueyellowwhite; whiteyellowblue];
    
    
    img = zeros(ngrid+borderwidth*2);
    if (SVR.SamplesTrainedNumber>0)
        for i=1:ngrid+borderwidth*2
            row = ngrid+borderwidth*2-round((ygrid(i)-ymin)/ystep);
            img(:,i) = bandwidth-(row-(1:ngrid+borderwidth*2)'); 
        end
    else
        for i=1:ngrid+borderwidth*2            
            row = (ngrid+borderwidth*2)/2;
            img(:,i) = bandwidth-(row-(1:ngrid+borderwidth*2)'); 
        end
    end
    img(img<1)=1;
    
    img = image(img);
    colormap(color)
    hold on
    
    for i=1:RemainingSetElementsNumber(SVR)
        row = round((SVR.X(SVR.RemainingSetIndexes(i))-xmin)/xstep);
        col = ngrid+borderwidth*2-round((SVR.Y(SVR.RemainingSetIndexes(i))-ymin)/ystep);
        plot (row, col, 'O','LineWidth',5, 'MarkerEdgeColor','g', 'MarkerFaceColor','g', 'MarkerSize',4);
        plot (row, col, 'Ok');
    end 
    for i=1:ErrorSetElementsNumber(SVR)
        row = round((SVR.X(SVR.ErrorSetIndexes(i))-xmin)/xstep);
        col = ngrid+borderwidth*2-round((SVR.Y(SVR.ErrorSetIndexes(i))-ymin)/ystep);        
        plot (row, col, 'O','LineWidth',5, 'MarkerEdgeColor','r', 'MarkerFaceColor','r', 'MarkerSize',4);
        plot (row, col, 'Ok');
    end   
    for i=1:SupportSetElementsNumber(SVR)
        row = round((SVR.X(SVR.SupportSetIndexes(i))-xmin)/xstep);
        col = ngrid+borderwidth*2-round((SVR.Y(SVR.SupportSetIndexes(i))-ymin)/ystep);        
        plot (row, col, 'O','LineWidth',5, 'MarkerEdgeColor','y', 'MarkerFaceColor','y', 'MarkerSize',4);
        plot (row, col, 'Ok');
    end       
    if (SVR.SamplesTrainedNumber > SupportSetElementsNumber(SVR)+ErrorSetElementsNumber(SVR)+RemainingSetElementsNumber(SVR))
        row = round((SVR.X(SVR.SamplesTrainedNumber)-xmin)/xstep);
        col = ngrid+borderwidth*2-round((SVR.Y(SVR.SamplesTrainedNumber)-ymin)/ystep);        
        plot (row, col, 'O','LineWidth',5, 'MarkerEdgeColor',[1 0.5 0], 'MarkerFaceColor','g', 'MarkerSize',4);
        plot (row, col, 'Ok');        
    end
    
    if (exist('ShowAxis') && ShowAxis==false)
        set(gca,'Visible','off');
    end
    
    % X Axe
    xticks = get(gca,'XTickLabel');
    nxticks = length(xticks);
    xstep = (xmax-xmin)/(nxticks);
    xticks = xmin+xstep:xstep:xmax;
    set(gca,'XTickLabel',xticks);
    %xlabel('X');

    % Y Axe
    yticks = get(gca,'YTickLabel');
    nyticks = length(yticks);
    ystep = (ymax-ymin)/(nyticks);
    yticks = ymax-ystep:-ystep:ymin;
    set(gca,'YTickLabel',yticks);
    %ylabel('Y');

    
    % Add the plot to the video
    if (SVR.MakeVideo)
        SVR.FramesNumber = SVR.FramesNumber + 1;
        ImagePath = ['Temporary OnlineSVR Files/' num2str(SVR.FramesNumber) '.png'];
        saveas(gcf,ImagePath);
    end
    
end

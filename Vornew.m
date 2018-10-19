n=5;
crs = [0,0;0,10;10,10;10,0];
numIterations = 100;
showPlot = true;
r_sen = 2;   %sensor range

Px = 0.5*rand([n,1]);
Py = 0.5*rand([n,1]);

xrange = max(crs(:,1));
yrange = max(crs(:,2));

%Dividing the area into discrete cells and expressing range in terms of the
%map
X1 = max(max(crs))/1000;
r_sen = r_sen/X1;
Z = ones(1000,1000);%Uncertainity Distribution
val2 = Z;
k=1;

%%%%%%%%%%%%%%%%%%%%%%%% VISUALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if showPlot
    verCellHandle = zeros(n,1);
    cellColors = ones(n,3);
    for i = 1:numel(Px) % color according to
        verCellHandle(i)  = patch(Px(i),Py(i),cellColors(i,:)); % use color i  -- no robot assigned yet
        hold on
    end
    pathHandle = zeros(n,1);
    %numHandle = zeros(n,1);
    for i = 1:numel(Px) % color according to
        pathHandle(i)  = plot(Px(i),Py(i),'-','color',cellColors(i,:)*.8);
        %    numHandle(i) = text(Px(i),Py(i),num2str(i));
    end
    goalHandle = plot(Px,Py,'+','linewidth',2);
    currHandle = plot(Px,Py,'o','linewidth',2);
    titleHandle = title(['o = Robots, + = Goals, Iteration ', num2str(0)]);
end
%%%%%%%%%%%%%%%%%%%%%%%% END VISUALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Starting the loop for search
%while max(max(Z))>0.1

% Iteratively Apply LLYOD's Algorithm
for counter = 1:numIterations
    
    %[v,c]=VoronoiLimit(Px,Py, crs, false);
    [v,c]=VoronoiBounded(Px,Py, crs);
    
    if showPlot
        set(currHandle,'XData',Px,'YData',Py);%plot current position
        for i = 1:numel(Px) % color according to
            xD = [get(pathHandle(i),'XData'),Px(i)];
            yD = [get(pathHandle(i),'YData'),Py(i)];
            set(pathHandle(i),'XData',xD,'YData',yD);%plot path position
            %       set(numHandle(i),'Position',[ Px(i),Py(i)]);
        end
    end
    
    for i = 1:numel(c) %calculate the centroid of each cell
        [cx,cy] = PolyCentroid(v(c{i},1),v(c{i},2));
        cx = min(xrange,max(0, cx));
        cy = min(yrange,max(0, cy));
        if ~isnan(cx) && inpolygon(cx,cy,crs(:,1),crs(:,2))
            Px(i) = cx;  %don't update if goal is outside the polygon
            Py(i) = cy;
        end
    end
    
    if showPlot
        for i = 1:numel(c) % update Voronoi cells
            set(verCellHandle(i), 'XData',v(c{i},1),'YData',v(c{i},2));
        end
        
        set(titleHandle,'string',['o = Robots, + = Goals, Iteration ', num2str(counter,'%3d')]);
        set(goalHandle,'XData',Px,'YData',Py);%plot goal position
        
        axis equal
        axis([0,xrange,0,yrange]);
        drawnow
    end
end
val = Z;
for i = 1:n
    BW = roipoly(Z,100*v(c{i},1),100*v(c{i},2));
    GI = mat2gray(BW);
    s = regionprops(BW, GI, {'Centroid','WeightedCentroid'});
    for m=1:1000
        for j=1:1000
            vx = s.WeightedCentroid(1,1);
            vy = s.WeightedCentroid(1,2);
            dist = sqrt(((m+0.5)-vx)^2+((j+0.5)-vy)^2)/100;
            if dist < r_sen
                val(j,m) = min(val(j,m),(1-0.8708+0.074*dist^2));
            end
        end
    end
end
for m=1:1000
    for j=1:1000
        Z(j,m) = Z(j,m)*val(j,m);
        val2(j,m) = 2*Z(j,m)*0.074;
    end
end
max_d(k)= max(max(Z));
average(k) = mean2(Z); 
k=k+1;
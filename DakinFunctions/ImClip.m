%ImClipfunction [res x1 x2 y1 y2]=ste(im,NewSize)[m n p]=size(im);	if exist('NewSize')        res(:,:,p)=zeros(NewSize(1),NewSize(2));        for pLoop=1:p            m1=NewSize(1);            n1=NewSize(2);            res(:,:,p)=im(1,1);            mstart=round((m-m1)/2)+1;            nstart=round((n-n1)/2)+1;            res(:,:,pLoop)=im(mstart:mstart+m1-1,nstart:nstart+n1-1,pLoop);        end    else        for pLoop=1:p            x1=sum(im');            a1=find(x1>0);            if ~isempty(a1)                x1=a1(1);                x2=a1(end);            else                x1=1; x2=length(im');            end            y1=sum(im);            a1=find(y1>0);            if ~isempty(a1)                y1=a1(1);                y2=a1(end);            else                y1=1; y2=length(im);            end            res(:,:,pLoop)=im(x1:x2,y1:y2);                end    end% for pLoop=1:p% 	if exist('NewSize')% 		m1=NewSize(1);% 		n1=NewSize(2);% 		res(:,:,p)=im(1,1);% 		mstart=round((m-m1)/2)+1;% 		nstart=round((n-n1)/2)+1;%         pLoop% 		res(:,:,p)=im(mstart:mstart+m1-1,nstart:nstart+n1-1,p);% 	else% 		x1=sum(im');% 		a1=find(x1>0);% 		if ~isempty(a1)% 			x1=a1(1);% 			x2=a1(end);% 		else% 			x1=1; x2=length(im');% 		end% 		y1=sum(im);% 		a1=find(y1>0)% 		if ~isempty(a1)% 			y1=a1(1);% 			y2=a1(end);% 		else% 			y1=1; y2=length(im);% 		end% 		res(:,:,p)=im(x1:x2,y1:y2);% 	end% end% 	
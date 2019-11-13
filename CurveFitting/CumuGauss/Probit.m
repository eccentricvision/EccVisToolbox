% Probit

function [anal_sd,sderr,anal_ed50,ed50err]=Probit(StimList,RespList,NoPresentedList)
 
     analtype=1;
     iterations = 40;
     apelength=sum(NoPresentedList);
		no_levels=length(StimList);
        srtable.stim=StimList;
		srtable.test=NoPresentedList;
		srtable.resp=RespList;
		srtable.prop=srtable.resp./srtable.test;  
		srtable.prob=ApeProbit(srtable.prop); 
		srtable.weight=ones(1,no_levels);

%  % /* first (unweighted) regression */
      [a,aerr,b,berr,chi,dof,overflow]= ApeRegress(srtable,no_levels);
     if (overflow) 
		b = 0.0;
		a = 0.0;
	else
     	cycles = 0;
     	az = a + 1.0;
     	bz = b + 1.0;
	    while ((cycles<iterations)&(abs(a-az)>0.001)&(abs(b-bz)>0.001)&(~overflow))
		% calculate working probits & weights */
			exprob = srtable.stim.*b+a;		
			exprtn = ApeInvProbit(exprob);
			z = exp(-exprob.*exprob/2.0) ./ 2.506628;
			srtable.weight=zeros(1,no_levels);
			ind2=find((z ~= 0.0) & (exprtn ~= 0.0));
			srtable.prob(ind2)=exprob(ind2)+(srtable.prop(ind2)-exprtn(ind2))/z(ind2);
            srtable.weight(ind2) = ((z(ind2).^2)./(exprtn(ind2).*(1.0-exprtn(ind2)))).* NoPresentedList(ind2);
			az = a;
			bz = b;
    		[a,aerr,b,berr,chi,dof,overflow]= ApeRegress(srtable,no_levels);
 	        cycles = cycles +1;
		end  
	    if (abs(b) <= 0.0001)  
			b = 0.0001; 
		end
	end
    anal_sd   = 1.0/b;
    sderr     = abs(berr/b/b);
    anal_ed50 = -a/b;
    ed50err   = abs(aerr/b); 
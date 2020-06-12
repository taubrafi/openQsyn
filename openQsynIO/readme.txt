This requires the following:

        function obj = power(A,n)
            %Power A^n
            obj = qexpression(A,n,'^');
        end
		
To be added to the file qpar.m
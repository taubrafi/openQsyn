function [outpars] = Export_params(inpars)
for i = 1:numel(inpars)
    inpar = inpars(i);
    name = inpar.name;
    lbnd = inpar.lower;
    ubnd = inpar.upper;
    nom = inpar.nominal;
    
    outpar = ureal(name,nom,'Range', [lbnd,ubnd]);
    outpars(i) = outpar;
end

end


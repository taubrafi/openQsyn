function H = makePZgain(DCgain,MID,HFgain)

w = MID(1);  m = MID(2);
p = w*sqrt(((HFgain/m)^2-1)/(1-(DCgain/m)^2));
H = tf([HFgain DCgain*p],[1 p]);

end


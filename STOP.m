function STOP
  ST = dbstack;
  if length(ST) < 2; return; end
  %dbstop('in', ST(2).file, 'at', str2num(ST(2).line+1));
  %dbstop('in', ST(2).file, 'at',(ST(2).line+1));
  eval(sprintf('dbstop in %s at %d',ST(2).file,ST(2).line+1))
end

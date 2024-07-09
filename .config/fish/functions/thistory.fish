function thistory --wraps=history\ --show-time=\'\%Y-\%m-\%d\ \%H:\%M:\%S\ \' --description alias\ thistory\ history\ --show-time=\'\%Y-\%m-\%d\ \%H:\%M:\%S\ \'
  history --show-time='%Y-%m-%d %H:%M:%S ' $argv
        
end

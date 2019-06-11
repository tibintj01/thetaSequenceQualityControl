function [] =setTickDirOut()
        set(findall(gcf,'-property','tickdir'),'tickdir','out')

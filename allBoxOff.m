function [] =allBoxOff()
        set(findall(gcf,'-property','box'),'box','off')

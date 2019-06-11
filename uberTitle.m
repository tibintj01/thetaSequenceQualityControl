function [] = uberTitle(titleStr,FontSizeTitle)

axes( 'Position', [0, 0.95, 1, 0.05] ) ;
 set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;

if(exist('FontSizeTitle'))
 text( 0.5, 0, titleStr, 'FontSize', FontSizeTitle, 'FontWeight', 'Bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
else
 text( 0.5, 0, titleStr, 'FontSize', 14', 'FontWeight', 'Bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;

end
        ax = gca
        ax.Visible = 'off'

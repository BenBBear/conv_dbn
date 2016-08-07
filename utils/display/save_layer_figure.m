function save_layer_figure( layers, idx )
global crbm_cache_path
if idx > 1
    display_network(layers{idx}, layers{idx-1}.display_result);
else
    display_network(layers{idx}, []);
end
save_current_figure(strcat(crbm_cache_path, 'Layer',num2str(idx),'_Visualization.png'));
end


function save_env(layers, id)
    global crbm_cache_path
    env.layers = layers;
    env.id = id;
    save(strcat(crbm_cache_path, env.id, '.mat'), 'env', '-v7.3');
end
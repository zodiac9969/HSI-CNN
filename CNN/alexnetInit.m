%   AlexNet Model Initialization

function net = alexnetInit(varargin)
opts.networkType = 'simplenn' ;
opts = vl_argparse(opts, varargin) ;

lr = [.1 2] ;

% Define network CIFAR10-quick
net.layers = {} ;

% Block 1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.01*randn(5,5,1,32, 'single'), zeros(1, 32, 'single')}}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'pad', 2) ;
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu') ;%7*7

% Block 2
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.05*randn(4,4,32,32, 'single'), zeros(1,32,'single')}}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'pad', 2) ;
net.layers{end+1} = struct('type', 'relu') ;
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'avg', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0) ; % Emulate caffe 4*4

% Block 3
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.05*randn(5,5,32,64, 'single'), zeros(1,64,'single')}}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'pad', 2) ;
net.layers{end+1} = struct('type', 'relu');
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'avg', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0); % Emulate caffe 4*4

% Block 4
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.05*randn(2,2,64,64, 'single'), zeros(1,64,'single')}}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

% Block 5
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.05*randn(1,1,64,16, 'single'), zeros(1,16,'single')}}, ...
                           'learningRate', .1*lr, ...
                           'stride', 1, ...
                           'pad', 0) ;

% Loss layer
net.layers{end+1} = struct('type', 'softmaxloss') ;

% Meta parameters
net.meta.inputSize = [14 14 1] ;
net.meta.trainOpts.learningRate = [0.05*ones(1,50) 0.005*ones(1,30) 0.0005*ones(1,20)] ;
net.meta.trainOpts.weightDecay = 0.0001 ;
net.meta.trainOpts.batchSize = 100 ;
net.meta.trainOpts.numEpochs = numel(net.meta.trainOpts.learningRate) ;

% Fill in default values
net = vl_simplenn_tidy(net) ;

% Switch to DagNN if requested
switch lower(opts.networkType)
  case 'simplenn'
    % done
  case 'dagnn'
    net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;
    net.addLayer('error', dagnn.Loss('loss', 'classerror'), ...
             {'prediction','label'}, 'error') ;
  otherwise
    assert(false) ;
end


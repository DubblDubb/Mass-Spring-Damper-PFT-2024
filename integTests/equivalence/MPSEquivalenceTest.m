classdef MPSEquivalenceTest < matlabtest.compiler.TestCase
    % This is a MATLAB Unit Test

    properties(TestParameter)
        % Can define different runtime inputs for the equivalence test
        % For now we will just run against 1 data point
        damping = struct(...
           ... "OverDamped", 5e5, ...
           ... "UnderDamped", 1e4, ...
            "CriticallyDamped", 5.477225575051661e4)
    end

    methods(TestClassSetup)
        function filterOnMac(testCase)
            testCase.assumeReturnsTrue(@() ~ismac, ...
                "MPS equivalence tests not supported on the mac");
        end
    end
   
    methods (Test)
        function mpsShouldBeEquivalentForDamping(testCase, damping)
            % Validate that MPS execution is equivalent to MATLAB for
            % various damping coefficient designs

            % Load the data we built via the build process
            disp("Loading MPS build results")
            prj = currentProject;
            loadedData = load(prj.RootFolder + "/results/ctf-build-results.mat"); % metadata .mat file from the buil
            buildResults = loadedData.buildResults;

            % Execute the runtime inputs (damping) on the server
            disp("Executing design on a local Production Server")
            design.k = 5e5;
            design.c = damping;
            executionResults = testCase.execute(buildResults,{design},"simulateSystem");
            
            % Verify server execution is equivalent to the local results
            disp("Verifying results match MATLAB results")
            % Note: Fails due to a bug which is fixed in the R2024a GR
            % testCase.verifyExecutionMatchesMATLAB(executionResults);
            % %<--more convient and better diagnostics.  Use when GR
            % shipps!

            % Verification workaround - not needed in GR. Note this
            % solution is not only less convenient, but also does not
            % produce diagnostics as valuable as the above method
            [x, t] = simulateSystem(design);
            testCase.verifyEqual(executionResults.ExecutableOutput, {x, t});
        end
    end
end

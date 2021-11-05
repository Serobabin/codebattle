import React, { useCallback, memo } from 'react';
import { useDispatch } from 'react-redux';
import SolutionTypeCodes from '../config/solutionTypes';
import { changePlaybookSolution } from '../middlewares/Game';

const ApprovePlaybookButtons = ({ playbookSolutionType }) => {
    const dispatch = useDispatch();
    const approve = useCallback(() => {
        dispatch(changePlaybookSolution('approve'));
    }, [dispatch]);
    const reject = useCallback(() => {
        dispatch(changePlaybookSolution('reject'));
    }, [dispatch]);

    switch (playbookSolutionType) {
        case SolutionTypeCodes.waitingModerator: return (
          <>
            <div className="d-flex btn-block">
              <button type="button" className="btn btn-outline-primary flex-grow-1 mr-1" onClick={approve}>Approve</button>
              <button type="button" className="btn btn-outline-danger flex-grow-1 ml-1" onClick={reject}>Ban</button>
            </div>
          </>
);
        case SolutionTypeCodes.complete: return (
          <>
            <button type="button" className="btn btn-block btn-outline-danger" onClick={reject}>To baned list</button>
          </>
);
        case SolutionTypeCodes.baned: return (
          <>
            <button type="button" className="btn btn-block btn-outline-primary" onClick={approve}>To approved list</button>
          </>
);
        default: return <></>;
    }
};

export default memo(ApprovePlaybookButtons);

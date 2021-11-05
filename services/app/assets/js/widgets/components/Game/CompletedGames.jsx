import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import moment from 'moment';
import ResultIcon from './ResultIcon';
import UserInfo from '../../containers/UserInfo';
import GameLevelBadge from '../GameLevelBadge';

const CompletedGames = ({ games, loadNextPage = null }) => {
  const { nextPage, totalPages } = useSelector(state => state.completedGames);
  const dispatch = useDispatch();

  return (
    <div className="table-responsive">
      <table className="table table-sm table-striped border-gray border mb-0">
        <thead>
          <tr>
            <th className="p-3 border-0">Level</th>
            <th className="p-3 border-0 text-center" colSpan={2}>
              Players
            </th>
            <th className="p-3 border-0">Date</th>
            <th className="p-3 border-0">Actions</th>
          </tr>
        </thead>
        <tbody>
          {games.map(game => (
            <tr key={game.id}>
              <td className="p-3 align-middle text-nowrap">
                <GameLevelBadge level={game.level} />
              </td>
              <td className="p-3 align-middle text-nowrap cb-username-td text-truncate">
                <div className="d-flex align-items-center">
                  <ResultIcon gameId={game.id} player1={game.players[0]} player2={game.players[1]} />
                  <UserInfo user={game.players[0]} />
                </div>
              </td>
              <td className="p-3 align-middle text-nowrap cb-username-td text-truncate">
                <div className="d-flex align-items-center">
                  <ResultIcon gameId={game.id} player1={game.players[1]} player2={game.players[0]} />
                  <UserInfo user={game.players[1]} />
                </div>
              </td>
              <td className="p-3 align-middle text-nowrap">{moment.utc(game.finishsAt).local().format('MM.DD HH:mm')}</td>
              <td className="p-3 align-middle">
                <a type="button" className="btn btn-outline-orange btn-sm" href={`/games/${game.id}`}>
                  Show
                </a>
              </td>
            </tr>
        ))}
        </tbody>
      </table>
      { loadNextPage !== null && nextPage <= totalPages
        ? (
          <button type="button" className="mt-2 btn btn-light" onClick={() => dispatch(loadNextPage(nextPage))}>
            Show More
          </button>
          ) : null}
    </div>
  );
};

export default CompletedGames;

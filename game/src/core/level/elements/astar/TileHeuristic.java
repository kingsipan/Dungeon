package core.level.elements.astar;

import com.badlogic.gdx.ai.pfa.Heuristic;
import com.badlogic.gdx.math.Vector2;

import core.level.Tile;

/**
 * @author Marti Stuwe
 */
public class TileHeuristic implements Heuristic<Tile> {

    /**
     * Heuristic used by the pathfinding algorithm
     *
     * @param start From
     * @param goal To
     * @return Distance between from and to tile
     */
    @Override
    public float estimate(Tile start, Tile goal) {
        return Vector2.dst2(
                start.coordinate().x,
                start.coordinate().y,
                goal.coordinate().x,
                goal.coordinate().y);
    }
}

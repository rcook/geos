{-# OPTIONS_GHC -fno-warn-orphans #-}
{-|
Module      : GEOS.Prepared

An interface for classes which prepare Geometrys in order to optimize the performance of repeated calls to specific geometric operations.

A given implementation may provide optimized implementations for only some of the specified methods, and delegate the remaining methods to the original Geometry operations. An implementation may also only optimize certain situations, and delegate others. See the implementing classes for documentation about which methods and situations they optimize.

-}

module GEOS.Prepared (
    prepare
  , contains
  , containsProperly
  , coveredBy
  , covers
  , crosses
  , disjoint
  , intersects
  , overlaps
  , touches
  , within
) where 

import qualified GEOS.Raw.Prepared as RP
import qualified GEOS.Raw.Geometry as RG
import GEOS.Raw.Base
import qualified GEOS.Geometry as G
import GEOS.Types
import Control.Monad

prepare :: Geometry a -> RP.PreparedGeometry
prepare = runGeos . (G.convertGeometryToRaw >=> RP.prepare)

queryPrepared :: (RP.PreparedGeometry -> RG.Geometry -> Geos Bool) 
                  -> RP.PreparedGeometry
                  -> Geometry a
                  -> Bool 
queryPrepared f pg g = runGeos $ G.convertGeometryToRaw g >>= (f pg)

instance Geo (RP.PreparedGeometry) where
  contains = queryPrepared RP.contains
  coveredBy = queryPrepared RP.coveredBy 
  covers = queryPrepared RP.covers 
  crosses = queryPrepared RP.crosses 
  disjoint = queryPrepared RP.disjoint 
  intersects = queryPrepared RP.intersects 
  overlaps = queryPrepared RP.overlaps
  touches = queryPrepared RP.touches 
  within = queryPrepared RP.within 

-- | The containsProperly predicate has the following equivalent definitions:

-- | Every point of the other geometry is a point of this geometry's interior. In other words, if the test geometry has any interaction with the boundary of the target geometry the result of containsProperly is false. This is different semantics to the @contains@ predicate, in which test geometries can intersect the target's boundary and still be contained.

-- | The advantage of using this predicate is that it can be computed efficiently, since it avoids the need to compute the full topological relationship of the input boundaries in cases where they intersect.

-- | An example use case is computing the intersections of a set of geometries with a large polygonal geometry. Since intersection is a fairly slow operation, it can be more efficient to use containsProperly to filter out test geometries which lie wholly inside the area. In these cases the intersection is known a priori to be exactly the original test geometry.


containsProperly :: RP.PreparedGeometry
                  -> Geometry a
                  -> Bool 
containsProperly = queryPrepared RP.containsProperly

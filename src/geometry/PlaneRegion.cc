/*
 Copyright (c) 2019, Triad National Security, LLC
 All rights reserved.

 Copyright 2019. Triad National Security, LLC. This software was
 produced under U.S. Government contract 89233218CNA000001 for Los
 Alamos National Laboratory (LANL), which is operated by Triad
 National Security, LLC for the U.S. Department of Energy. 
 All rights in the program are reserved by Triad National Security,
 LLC, and the U.S. Department of Energy/National Nuclear Security
 Administration. The Government is granted for itself and others acting
 on its behalf a nonexclusive, paid-up, irrevocable worldwide license
 in this material to reproduce, prepare derivative works, distribute
 copies to the public, perform publicly and display publicly, and to
 permit others to do so

 
 This is open source software distributed under the 3-clause BSD license.
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. Neither the name of Triad National Security, LLC, Los Alamos
    National Laboratory, LANL, the U.S. Government, nor the names of its
    contributors may be used to endorse or promote products derived from this
    software without specific prior written permission.

 
 THIS SOFTWARE IS PROVIDED BY TRIAD NATIONAL SECURITY, LLC AND
 CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
 BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 TRIAD NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/
/**
 * @file   PlaneRegion.cc
 * @author Rao Garimella
 * @date
 *
 * @brief  Implementation of PlaneRegion class
 *
 *
 */

#include "PlaneRegion.hh"
#include "dbc.hh"
#include "errors.hh"

namespace JaliGeometry {

// -------------------------------------------------------------
//  class PlaneRegion
// -------------------------------------------------------------

// -------------------------------------------------------------
// PlaneRegion:: constructors / destructor
// -------------------------------------------------------------
PlaneRegion::PlaneRegion(const std::string name,
			 const unsigned int id,
			 const Point& p, const Point& normal,
                         const LifeCycle_type lifecycle)
  : Region(name,id,p.dim()-1,lifecycle), p_(p), n_(normal)
{

  if (p_.dim() != n_.dim()) {
    std::stringstream tempstr;
    tempstr << "\nMismatch in point and normal dimensions of PlaneRegion " << Region::name() << "Perhaps the region is improperly defined?\n";
    Errors::Message mesg(tempstr.str());
    Exceptions::Jali_throw(mesg);
  }

}

PlaneRegion::PlaneRegion(const PlaneRegion& old)
  : Region(old), p_(old.p_), n_(old.n_)
{
  // empty
}

PlaneRegion::~PlaneRegion(void)
{

}

// -------------------------------------------------------------
// PlaneRegion::inside -- check if point is on plane
// -------------------------------------------------------------
bool
PlaneRegion::inside(const Point& p) const
{

  if (p.dim() != p_.dim()) {
    std::stringstream tempstr;
    tempstr << "\nMismatch in point dimension of PlaneRegion \"" << Region::name() << "\" and query point.\n Perhaps the region is improperly defined?\n";

    Errors::Message mesg(tempstr.str());
    Exceptions::Jali_throw(mesg);
  }

  bool result(true);

  double d(0.0), res(0.0);

  for (int i = 0; i < p.dim(); ++i)
    {
      res += n_[i]*p[i];
      d += n_[i]*p_[i];
    }
  res -= d;

  if (fabs(res) <= 1.0e-12)
    result = true;
  else
    result = false;

  return result;
}

} // namespace JaliGeometry
